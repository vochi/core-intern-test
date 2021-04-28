#include <iostream>

namespace test {
namespace cli {

class ProgressBar {
public:
    ProgressBar(std::ostream& str, int total=-1, std::string desc="", int width=70, char fg='#', char bg='-') 
    : _stream(str), _desc(desc), _total(total), _width(width), _bg(bg), _fg(fg), _status(0), _closed(false)
    { }

    ~ProgressBar() {
        close();
    }

    void update(size_t count=1) {
        std::lock_guard lock(_mutex);
        _status += count;
        draw();
    }

    void draw() {
        std::lock_guard lock(_mutex);

        std::ostringstream prefix;
        if (_desc != "") {
            prefix << _desc << "| ";
        }
        prefix << _status << "/" << _total;
        prefix << " [";

        std::string prefixStr = prefix.str();

        _stream << prefixStr;

        size_t width = std::max(0, int(_width - prefixStr.size() - 1));

        if (_status * width / _total > (_status-1) * width / _total) {
            for (int i = 0; i < _status*width/_total; ++i) {
                _stream << _fg;
            }
            for (int i = _status*width/_total; i < width; ++i) {
                _stream << _bg;
            }
            _stream << "]";
        }

        _stream << "\r";
        _stream.flush();
    }

    void close() {
        std::lock_guard lock(_mutex);
        if (!_closed) {
            _stream << std::endl;
            _closed = true;
        }
    }


private:
    int                     _total;
    std::string             _desc;
    char                    _fg;
    char                    _bg;
    size_t                  _status;
    std::ostream&           _stream;
    size_t                  _width;
    bool                    _closed;
    std::recursive_mutex    _mutex;
};

} // namespace cli
} // namespace test
