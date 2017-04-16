#include <stdio.h>
#include <iostream>
#include <gflags/gflags.h>
#include <glog/logging.h>

// #include <folly/FileUtil.h>
#include <folly/String.h>


DEFINE_bool(big_menu, true, "Include 'advanced' options in the menu listing");

int main(int argc, char *argv[]) {
  FLAGS_logtostderr = true;
  gflags::SetVersionString("0.0.1");
  gflags::ParseCommandLineFlags(&argc, &argv, false);
  google::InitGoogleLogging(argv[0]);

  LOG(INFO) << "Starting";
  LOG(INFO) << folly::stringPrintf("test folly [%d]", 123);
  // LOG(INFO) << "Hello World";
  std::cout << "Hello World!" << std::endl;
  // std::cout << folly::stringPrintf("test folly [%d]", 123) << std::endl;
  return 0;
}
