#include <iostream>
#include "gtest/gtest.h"
#include "gmock/gmock.h"
#include "operate_err_code.h"
#include "hal_key.h"
#include "sdk_key.h"
#include "sdk_led.h"


TEST(TestKeyInit, Normal)
{
    operate_t opt = OPERATE_OK;

    ASSERT_EQ(opt, OPERATE_OK);
}

//未初始化，调用会返回错误
TEST(TestKeySet, Normal)
{
    // ::testing::NiceMock<MockHAL> mock_hal;
    // ::testing::NiceMock<MockSDKled> mock_led;
    // FakeSDKled fake_led;
    // fake_led.bind_to(mock_led);

    operate_t opt = sdk_key_set_status(KEY_NUM_1, KEY_STATUS_UP);

    ASSERT_EQ(opt, OPERATE_FAIL);
}

