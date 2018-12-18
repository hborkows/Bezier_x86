#include <iostream>
#include <SDL2/SDL.h>

const size_t nrPoints = 5;

extern "C" {void bezierFun(int* pX, int* pY, unsigned int* pixels, int imageWidth);}

int main()
{
    const size_t sizeX = 1000;
    const size_t sizeY = 900;
    bool quit = false;
    int px[nrPoints];
    int py[nrPoints];
    int mouseX;
    int mouseY;
    size_t pointCounter = 0;

    SDL_Event event;

    SDL_Init(SDL_INIT_VIDEO);

    SDL_Window* window = SDL_CreateWindow("SDL Test",
                                            SDL_WINDOWPOS_UNDEFINED,
                                            SDL_WINDOWPOS_UNDEFINED, sizeX, sizeY, 0);

    SDL_Renderer* renderer = SDL_CreateRenderer(window, -1, 0);
    SDL_Texture* texture = SDL_CreateTexture(renderer,
                                                SDL_PIXELFORMAT_ARGB8888,
                                                SDL_TEXTUREACCESS_STATIC, sizeX, sizeY);
    auto pixels = new Uint32[sizeX * sizeY];
    memset(pixels, 255, sizeX * sizeY * sizeof(Uint32)); //set pixel array to white
    
    while(!quit)
    {
        SDL_UpdateTexture(texture, nullptr, pixels, sizeX * sizeof(Uint32));
        SDL_WaitEvent(&event);

        switch(event.type)
        {
            case SDL_QUIT:
                quit = true;
                break;
            case SDL_MOUSEBUTTONUP:
                if (event.button.button == SDL_BUTTON_LEFT)
                {
                    mouseX = event.motion.x;
                    mouseY = event.motion.y;
                    std::cout << "( " << mouseX << " , " << mouseY << " )" << std::endl;
                    if(pointCounter < nrPoints)
                    {
                        px[pointCounter] = mouseX;
                        py[pointCounter] = mouseY;
                        pointCounter++;
                        if(pointCounter >= nrPoints)
                        {
                            std::cout << "drawing..." << std::endl;
                            bezierFun(px, py, pixels, sizeX);
                            SDL_UpdateTexture(texture, nullptr, pixels, sizeX * sizeof(Uint32));
                            pointCounter = 0;
                        }
                    }
                }
                break;
            default:
                break;
        }
        SDL_RenderClear(renderer);
        SDL_RenderCopy(renderer, texture, nullptr, nullptr);
        SDL_RenderPresent(renderer);
    }

    delete[] pixels;
    SDL_DestroyTexture(texture);
    SDL_DestroyRenderer(renderer);
    SDL_DestroyWindow(window);
    SDL_Quit();

    return 0;
}
