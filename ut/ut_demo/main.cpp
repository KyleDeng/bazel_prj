#include <iostream>
#include <gtest/gtest.h>
#include <gmock/gmock.h>
#include "foo.h"

Foo::~Foo()
{}

class MockFoo: public Foo {
public:
    virtual ~MockFoo() {};
    MOCK_METHOD(int, GetSize, (), (const, override));
    // MOCK_METHOD(std::string, Describe, (const char* name), (override));
    MOCK_METHOD(std::string, Describe, (int type), (override));
    MOCK_METHOD(bool, Process, (Bar elem, int count), (override));
};

std::string myFunc(Foo *foo)
{
    std::string s;
    s = foo->Describe(5);
    std::cout << "s: " << s << std::endl;
    if("Category 5" != s) {
        return "bad";
    }
    return "good";
}

TEST(FuncTest, HandlesZeroInput) {
    MockFoo foo;
    testing::Sequence s1, s2;

    EXPECT_CALL(foo, Describe(1))
        .InSequence(s1, s2)
        .WillOnce(testing::Return("Category 1"));

    EXPECT_CALL(foo, Describe(2))
        .InSequence(s1)
        .WillOnce(testing::Return("Category 2"));

    EXPECT_CALL(foo, Describe(3))
        .InSequence(s2)
        .WillOnce(testing::Return("Category 3"));

    std::cout << foo.Describe(1) << std::endl;
    std::cout << foo.Describe(2) << std::endl;
    std::cout << foo.Describe(3) << std::endl;
}

int main(int argc, char* argv[])
{
    std::cout << "gtest begin..." << std::endl;

    ::testing::InitGoogleMock(&argc, argv);
    ::testing::InitGoogleTest(&argc, argv);
    return RUN_ALL_TESTS();
}
