#include <iostream>
#include "gtest/gtest.h"
#include "gmock/gmock.h"


class Environment : public ::testing::Environment
{
public:
    virtual ~Environment() {}

    // Override this to define how to set up the environment.
    void SetUp() override
    {
        std::cout << "===== SetUp =====" << std::endl;
    }

    // Override this to define how to tear down the environment.
    void TearDown() override
    {
        std::cout << "----- TearDown -----" << std::endl;
    }
};


int main(int argc, char *argv[])
{
    ::testing::InitGoogleTest(&argc, argv);
    ::testing::AddGlobalTestEnvironment(new Environment());
    return RUN_ALL_TESTS();
}

