#include "c99/gfx.h"

struct sapp_event;

extern "C"
{
    GfxSetup* GetGfxSetup();
    void OnInit();
    void OnFrame();
    void OnCleanUp();
    void OnEvent(const sapp_event* _event);
    void OnFail();

    // Beef
    void BeefMain(int argc, char** argv);   
}