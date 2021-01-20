#ifdef ARI_ANDROID
#define SOKOL_IMPL
#define SOKOL_WIN32_FORCE_MAIN
#define SOKOL_GLES3
#include "sokol_app.h"
#include "sokol_gfx.h"
#include "sokol_glue.h"
//#include "c99/io.h"  
#include "main.h"
#include <unistd.h>
#include <pthread.h>
#include "gfx/gfx.hpp"
 

 sg_pass_action pass_action;   
 pthread_t beef_thread;
 
void ari_init_cb()
{  
	sg_desc desc;
	memset(&desc, 0, sizeof(sg_desc)); 
	desc.context = sapp_sgcontext(); 
	sg_setup(&desc);

	// Setup shaders	
	ari::gfx::SetupShaders();

    OnInit(); 
}

void ari_frame_cb() 
{
    OnFrame();
}

void ari_cleanup_cb()
{  
    OnCleanUp();
	sg_shutdown();
}

void ari_event_cb(const sapp_event* event)
{	
    OnEvent(event);
} 

void ari_fail_cb(const char* msg)
{
	OnFail();
}

static void *
thread_start(void *arg)
{ 
	BeefMain(0, nullptr); 
}

sapp_desc sokol_main(int argc, char* argv[]) {
	sapp_desc desc;
	memset(&desc, 0, sizeof(sapp_desc));
 
    // Init Beef in thread
	pthread_create(&beef_thread, nullptr, &thread_start, nullptr);
	sleep(1); 

    GfxSetup* setup = GetGfxSetup();
	while (setup == nullptr)  
	{ 
		sleep(1); 
		setup = GetGfxSetup(); 
	} 
	
    desc.width = setup->window.Width;
	desc.height = setup->window.Height;  
	desc.fullscreen = setup->window.FullScreen;
	desc.high_dpi = setup->window.HighDpi; 
	desc.sample_count = setup->sample_count;
	desc.swap_interval = setup->swap_interval;
 
	desc.init_cb = ari_init_cb;
	desc.frame_cb = ari_frame_cb;
	desc.cleanup_cb = ari_cleanup_cb;
	desc.event_cb = ari_event_cb;
	desc.fail_cb = ari_fail_cb;
 
	return desc;
}
#else
int main()
{
	return 0;
}
#endif