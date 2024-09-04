#pragma once

#if defined(CONFIG_PLATFORM_AMEBADPLUS)
#include <FreeRTOS.h>
#endif
#include <platform_stdlib.h>
#include <pwmout_api.h>

class MatterMicrowaveOven
{
public:
    void Init(PinName pin);
    void deInit(void);
    void setOpState(uint8_t state);

private:
    pwmout_t *mPwm_obj = NULL;
    uint8_t mOpState;
};
