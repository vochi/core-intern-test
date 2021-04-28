#include <chrono>
#include <fstream>
#include <iostream>
#include <opencv2/opencv.hpp>
#include <opencv2/core/utils/filesystem.hpp>
#include <stdexcept>
#include <functional>
#include <string>

#include "cli.h"

#include "effect.h"

int main(int argc, char* argv[])
{
    std::vector<std::string> frames;
    std::vector<std::string> masks;

    auto framespath = "frames/Hope/frames";
    auto maskspath = "frames/Hope/masks";

    cv::utils::fs::glob(framespath, "*.png", frames);
    if (frames.empty())
        cv::utils::fs::glob(framespath, "*.jpg", frames);
    cv::utils::fs::glob(maskspath, "*.png", masks);
    if (masks.empty())
        cv::utils::fs::glob(maskspath, "*.jpg", masks);
    std::sort(frames.begin(), frames.end());
    std::sort(masks.begin(), masks.end());

    cv::Size frameSize = cv::imread(frames[0]).size();

    cv::VideoWriter writer;
    auto fcc = "avc1";
    auto fourcc = cv::VideoWriter::fourcc(fcc[0], fcc[1], fcc[2], fcc[3]);

    auto outPath = "result.mp4";

//    auto ends_with = [](std::string const & value, std::string const & ending)
//    {
//        if (ending.size() > value.size()) return false;
//        return std::equal(ending.rbegin(), ending.rend(), value.rbegin());
//    };
//    if (ends_with(outPath, ".avi"))
//        fourcc = cv::VideoWriter::fourcc('M', 'J', 'P', 'G');

    if (!writer.open(outPath, fourcc, 30, frameSize)) {
        std::cout << ("Video writer failed");
    }

#define vch_timestamp() std::chrono::duration_cast<std::chrono::milliseconds>(std::chrono::steady_clock::now().time_since_epoch()).count()

    auto startT = vch_timestamp();

    auto bar = test::cli::ProgressBar(std::cout, frames.size());

    for (int i = 0; i < frames.size(); i++) {

        cv::Mat img = cv::imread(frames[i]);
        cv::resize(img, img, frameSize);
        cv::Mat mask = cv::imread(masks[i], cv::IMREAD_GRAYSCALE);
        mask.convertTo(mask, CV_32FC1, 1.f / 255);

        cv::resize(mask, mask, img.size());

        img = applyEffect(img, mask, i);

        writer.write(img);

        bar.update();
    }

    bar.close();

    auto perFrameT = (vch_timestamp() - startT) / frames.size();
    std::cout << "avg frame time, ms: " << perFrameT << std::endl;

    if (writer.isOpened())
        writer.release();

    return 0;
}
