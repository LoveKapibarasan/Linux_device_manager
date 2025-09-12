#include <fstream>
#include <iostream>
#include <string>

// g++ black-list.cpp -o black-list
// sudo ./black-list
// cat /etc/hosts


int main() {
    const std::string base_file = "host.txt";       // ベースとなるホスト設定
    const std::string csv_file  = "black-list.csv"; // ブラックリスト (ヘッダ address 付き)
    const std::string hosts_file = "/etc/hosts";    // 出力先

    std::ifstream base(base_file);
    if (!base.is_open()) {
        std::cerr << "Failed to open " << base_file << "\n";
        return 1;
    }

    std::ifstream csv(csv_file);
    if (!csv.is_open()) {
        std::cerr << "Failed to open " << csv_file << "\n";
        return 1;
    }

    std::ofstream hosts(hosts_file, std::ios::trunc); // 上書き (truncate)
    if (!hosts.is_open()) {
        std::cerr << "Failed to open " << hosts_file << " (need root?)\n";
        return 1;
    }

    // 1. host.txt の内容をコピー
    std::string line;
    while (std::getline(base, line)) {
        hosts << line << "\n";
    }

    // 2. CSV のドメインを追加
    bool first = true;
    hosts << "\n# Blacklist entries\n";
    while (std::getline(csv, line)) {
        if (!line.empty()) {
            hosts << "127.0.0.1 " << line << "\n";
            hosts << "::1 "       << line << "\n";   // IPv6 
        }
    }

    std::cout << hosts_file << " successfully generated!\n";
    return 0;
}
