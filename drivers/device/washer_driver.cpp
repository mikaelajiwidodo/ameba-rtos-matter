#include <washer_driver.h>

#include <support/logging/CHIPLogging.h>

void MatterWasher::Init(PinName pin)
{
    mPwm_obj                        = (pwmout_t*) pvPortMalloc(sizeof(pwmout_t));
    pwmout_init(mPwm_obj, pin);
#if defined(CONFIG_PLATFORM_8710C)
    pwmout_period_us(mPwm_obj, 20000); //pwm period = 20ms
    pwmout_start(mPwm_obj);
#endif
}

void MatterWasher::deInit(void)
{
    vPortFree(mPwm_obj);
}

void MatterWasher::Do(void)
{
    // implement action here
    ChipLogProgress(DeviceLayer, "Washer action");
}
