#include "effect.h"
#include <opencv2/opencv.hpp>

std::vector<cv::Point> maskContour(const cv::Mat& binMask);


// Implement your effect here
//BGR (red last) 8bit image, float32 1 channel mask
cv::Mat applyEffect(cv::Mat image, cv::Mat mask, int idx)
{
    cv::Mat intMask;
    mask.convertTo(intMask, CV_8UC1, 255);
    intMask = intMask > 128;

    auto contour = maskContour(intMask);

    bool showAnimated = (idx % 15) < 7; //use idx as time at 30 fps
    if (showAnimated) {
        for (int i = 0; i < contour.size()-1; i++) {
            cv::line(image, contour.at(i), contour.at(i+1), cv::Scalar{0, 99, 255}, 0.005 * image.size().width);
        }
    }

    return image;
}


//helpers

struct Contour {
    std::vector<cv::Point> points;
    bool inner;
};

std::vector<Contour> maskContours(const cv::Mat& binMask)
{

    std::vector<std::vector<cv::Point>> contours;
    std::vector<cv::Vec4i> hierarchy;
    cv::findContours(binMask, contours, hierarchy, cv::RETR_CCOMP, cv::CHAIN_APPROX_NONE);

    if (contours.empty()) {
        return {};
    }

    std::set<size_t> outterContoursSet;
    int next = 0;
    while(next != -1) {
        outterContoursSet.insert(next);
        next = hierarchy.at(next)[0];
    }

    std::vector<Contour> outterContours;
    std::vector<Contour> innerContours;

    for (int i = 0; i < contours.size(); ++i) {
        Contour cnt;
        cnt.points = std::move(contours[i]);
        auto outter = outterContoursSet.count(i);
        if (outter) {
            cnt.inner = false;
            outterContours.push_back(std::move(cnt));
        } else {
            cnt.inner = true;
            innerContours.push_back(std::move(cnt));
        }
    }

    auto maxContourIt = std::max_element(contours.begin(), contours.end(), [](auto& a, auto& b) {
        return a.size() < b.size();
    });
    auto maxContourIdx = std::distance(contours.begin(), maxContourIt);

    if (outterContoursSet.count(maxContourIdx) == 0) {
        std::swap(outterContours, innerContours);
        for (auto& cnt : outterContours) {
            cnt.inner = !cnt.inner;
        }
        for (auto& cnt : innerContours) {
            cnt.inner = !cnt.inner;
        }
    }

    std::sort(outterContours.begin(), outterContours.end(), [](auto& a, auto& b) {
        return a.points.size() > b.points.size();
    });
    std::sort(innerContours.begin(), innerContours.end(), [](auto& a, auto& b) {
        return a.points.size() > b.points.size();
    });

    outterContours.insert(outterContours.end(), innerContours.begin(), innerContours.end());

    return outterContours;
}

std::vector<cv::Point> maskContour(const cv::Mat& binMask)
{
    auto contours = maskContours(binMask);
    if (contours.empty()) {
        return {};
    }

    return contours.front().points;
}
