//
// Placeholder cpp file to declare SDL_MAIN_NEEDED
//

#include "main.hpp"

#include <SDL3/SDL_main.h>
#include <SDL3/SDL.h>
#include <SDL3/SDL_render.h>
#define SDL_MAIN_NEEDED

//extern int zig_main(int argc, char *argv[]);


//int main(int argc, char *argv[]) {
//    printf("cpp entry\n");
//
//    return zig_main(argc, argv);
//}

/*
#define SDL_MAIN_USE_CALLBACKS

SDL_Window *window;
SDL_Renderer *renderer;

SDL_AppResult SDL_AppInit(void **appstate, int argc, char **argv) {
    if (!SDL_Init(SDL_INIT_VIDEO)) {
        SDL_Log("Error initializing: %s", SDL_GetError());
        printf("init failed\n");
        return SDL_APP_FAILURE;
    }

    window = SDL_CreateWindow("testing", 600, 800, NULL);
    if (!window) {
        SDL_Log("Error creating window: %s", SDL_GetError());
        printf("create window failed\n");
        return SDL_APP_FAILURE;
    }

    renderer = SDL_CreateRenderer(window, NULL);
    if (!renderer) {
        SDL_Log("Error creating window: %s", SDL_GetError());
        printf("create window failed\n");
        return SDL_APP_FAILURE;
    }
    return SDL_APP_CONTINUE;
}

signed char helper();
void helper2();

SDL_AppResult SDL_AppIterate(void *appstate) {
    // Background
    SDL_SetRenderDrawColor(renderer, 50, 100, 200, 255);
    SDL_RenderClear(renderer);

    helper2();
    SDL_SetRenderDrawColor(renderer, helper(), 150, 250, 255);
    SDL_FRect rect = {50,50,240,290};
    SDL_RenderFillRect(renderer, &rect);

    SDL_RenderPresent(renderer);

    return SDL_APP_CONTINUE;
}

SDL_AppResult SDL_AppEvent(void *appstate, SDL_Event *event) {
    if (event->type == SDL_EVENT_QUIT) {
        return SDL_APP_SUCCESS;
    }
    return SDL_APP_CONTINUE;
}

void SDL_AppQuit(void *appstate, SDL_AppResult result) {
    printf("exiting\n");
    SDL_DestroyRenderer(renderer);
    renderer = NULL;
    SDL_DestroyWindow(window);
    window = NULL;
    SDL_Quit();
}

*/
