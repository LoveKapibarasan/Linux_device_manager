#include <iostream>
#include <fstream>
#include <chrono>
#include <thread>
#include <ctime>
#include <sys/stat.h>
#include <unistd.h>

void protectFileOnce(const std::string &path) {
    // chmod 700
    chmod(path.c_str(), 0700);
}

bool inRange(int x, int y) {
    time_t t = time(nullptr);
    struct tm *now = localtime(&t);
    int hour = now->tm_hour;  // 時間だけ見る場合

    return (x < hour && hour < y);
}

void updateRegexHosts(bool inside) {
    std::ofstream ofs("/etc/regexhosts");
    if (!ofs) {
        std::cerr << "Cannot open /etc/regexhosts\n";
        return;
    }

    if (inside) {
        ofs << "ALLOW .*example.com\n";
        ofs << "DENY .*badhost.net\n";
    } else {
        ofs << "# Outside range - different rules\n";
        ofs << "DENY .*everything\n";
    }
}

int main() {
    const std::string protectPaths = {
        "/etc/regexhosts",
        "/opt/change_profile/change_profile" // itself
        "/opt/change_profile/profile_restricted.csv";
        "/opt/change_profile"
    }
    for {

    }
    protectFileOnce(protectPath);

    while (true) {
        bool inside = inRange(8, 18);  // 例えば 8:00〜18:00 の間
        updateRegexHosts(inside);

        std::this_thread::sleep_for(std::chrono::minutes(5));
    }

    return 0;
}
