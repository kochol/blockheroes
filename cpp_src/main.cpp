    #include <EGL/egl.h>
    #if defined(SOKOL_GLES3)
        #include <GLES3/gl3.h>
    #else
        #ifndef GL_EXT_PROTOTYPES
            #define GL_GLEXT_PROTOTYPES
        #endif
        #include <GLES2/gl2.h>
        #include <GLES2/gl2ext.h>
    #endif

#define SOKOL_APP_IMPL
#define SOKOL_GFX_IMPL
#include "sokol_gfx.h"
#include "sokol_app.h"
#define SOKOL_GLUE_IMPL
#include "sokol_glue.h"
#include "c99/io.h"  
#include "main.h"
#include <unistd.h>
#include <pthread.h>
#include "gfx/gfx.hpp"

pthread_t beef_thread;

struct sapp_data
{
	_sapp_t* p_sapp;
	_sapp_android_t* p_sapp_android_state;
};

extern "C" sapp_data CreateSg(sg_context_desc _desc);
sapp_data g_sapp_data;

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
	//sg_shutdown();
}

void ari_event_cb(const sapp_event* event)
{
	*g_sapp_data.p_sapp = _sapp;
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
