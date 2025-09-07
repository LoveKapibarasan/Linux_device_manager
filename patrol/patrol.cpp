#include <iostream>
#include <fstream>
#include <chrono>
#include <thread>
#include <ctime>
#include <sys/stat.h>
#include <unistd.h>
#include <vector>
#include <string>
#include <array>
#include <pwd.h>
#include <cstdio>

// Check if current time is in the allowed (non-restricted) range
bool inRange() {
    time_t t = time(nullptr);
    struct tm *now = localtime(&t);
    int hour = now->tm_hour;
    return ((7 < hour && hour < 9) || (17 < hour && hour < 19));
}

// Write log to every user's home directory
void writeUserLogs(const std::string &msg) {
    struct passwd *pw;
    setpwent(); // rewind passwd file
    while ((pw = getpwent()) != nullptr) {
        if (pw->pw_uid >= 1000 && pw->pw_uid < 60000) { // normal users only
            std::string logPath = std::string(pw->pw_dir) + "/patrol.log";
            std::ofstream ofs(logPath, std::ios::app);
            if (ofs) {
                ofs << "[" << time(nullptr) << "] " << msg << "\n";
            }
        }
    }
    endpwent();
}

// Write to /etc/regexhosts
void updateRegexHosts(const std::string &content, const std::string &profileName) {
    std::ofstream ofs("/etc/regexhosts");
    if (!ofs) {
        std::string msg = "Cannot open /etc/regexhosts";
        std::cerr << msg << "\n";
        writeUserLogs(msg);
        return;
    }
    ofs << content;
    writeUserLogs("Applied " + profileName + " profile to /etc/regexhosts");
}

// Read a file and return its content as a string
std::string readFile(const std::string &path) {
    std::ifstream ifs(path);
    if (!ifs) {
        std::string msg = "Cannot open file: " + path;
        std::cerr << msg << "\n";
        writeUserLogs(msg);
        return "";
    }
    return std::string((std::istreambuf_iterator<char>(ifs)),
                       std::istreambuf_iterator<char>());
}

// Execute a command and log its output + exit code
void execAndLog(const std::string &exePath) {
    std::string cmd = "sudo " + exePath + " 2>&1"; // redirect stderr to stdout
    writeUserLogs("Executing: " + cmd);

    std::array<char, 256> buffer{};
    std::string result;

    FILE* pipe = popen(cmd.c_str(), "r");
    if (!pipe) {
        writeUserLogs("popen() failed for: " + cmd);
        return;
    }

    while (fgets(buffer.data(), buffer.size(), pipe) != nullptr) {
        result += buffer.data();
    }

    int ret = pclose(pipe);

    if (!result.empty()) {
        writeUserLogs("Command output:\n" + result);
    }
    writeUserLogs("Command finished: " + cmd + " (exit=" + std::to_string(ret) + ")");
}

int main() {
    std::string path1 = "/opt/patrol/profile_restricted.csv";
    std::string path2 = "/opt/patrol/profile.csv";

    std::string content1 = readFile(path1); // restricted profile
    std::string content2 = readFile(path2); // non-restricted profile

    std::string exePath = "/opt/patrol/patrol.sh";

    bool lastState = false; // remember last state of inRange()
    while (true) {
        bool nowState = inRange();
        if (nowState != lastState) {
            if (nowState) {
                updateRegexHosts(content2, "non-restricted");
            } else {
                updateRegexHosts(content1, "restricted");
                execAndLog(exePath); // run patrol.sh and log output
            }
            lastState = nowState;
        }
        std::this_thread::sleep_for(std::chrono::minutes(5));
    }
    return 0;
}
