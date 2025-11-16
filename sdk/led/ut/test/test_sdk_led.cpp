#include <iostream>
#include "gtest/gtest.h"
#include "gmock/gmock.h"
#include "mockcpp/mockcpp.hpp"
#include "operate_err_code.h"
#include "sdk_led.h"
// #include "mock_hal.h"


TEST(TestLedInit, Normal)
{
    operate_t opt = sdk_led_init();

    ASSERT_EQ(opt, OPERATE_OK);
}

TEST(TestLedDeinit, Normal)
{
    const char *ans = sdk_led_deinit();

    ASSERT_STREQ(ans, "deinit success");
}

// mock
int mock_hal_led_set(int n, int s)
{
    std::cout << "mock -> led " << n << ",set " << s << std::endl;
    return 1;
}

TEST(TestLedOn1, Normal)
{
    sdk_led_init();
    operate_t opt = sdk_led_set_status(LED_NUM_1, LED_STATUS_ON);

    ASSERT_EQ(opt, OPERATE_OK);
}

TEST(Flicker, Success)
{
    operate_t opt = sdk_led_flicker(LED_NUM_1);

    ASSERT_EQ(opt, OPERATE_OK);
}

// 同上的API，使用mockcpp改变内部逻辑
TEST(Flicker, Fail)
{
    MOCKER(sdk_led_get_status)
        .expects(exactly(1))
        .will(returnValue(OPERATE_FAIL));

    operate_t opt = sdk_led_flicker(LED_NUM_1);

    ASSERT_EQ(opt, OPERATE_FAIL);
    GlobalMockObject::verify();
}

TEST(Flicker, Success2)
{
    //如果没有verify或reset过，会继续使用mock过的sdk_led_get_status
    operate_t opt = sdk_led_flicker(LED_NUM_1);

    ASSERT_EQ(opt, OPERATE_OK);
}

