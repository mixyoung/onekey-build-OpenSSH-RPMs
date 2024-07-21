#!/bin/bash

# 函数: 获取最新的OpenSSL版本号
get_latest_openssl_version() {
  latest_version=$(curl -s https://www.openssl.org/source/ | grep -Po '(?<=<a href="openssl-)[^"]*(?=.tar.gz")')
  echo "$latest_version"
}

# 测试函数: 获取最新的OpenSSL版本号
test_get_latest_openssl_version() {
  # 调用函数获取最新版本号
  latest_version=$(get_latest_openssl_version)
  
  # 验证最新版本号是否非空
  if [ -z "$latest_version" ]; then
    echo "Failed to get the latest OpenSSL version: $latest_version"
    return 1
  fi
  
  echo "Latest OpenSSL version is: $latest_version"
  return 0
}

# 主函数，运行所有的单元测试
function run_tests() {
  test_get_latest_openssl_version
}

# 运行所有的单元测试
run_tests