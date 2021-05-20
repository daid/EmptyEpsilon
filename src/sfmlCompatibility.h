#ifndef EE_SFML_COMPATIBILITY_H
#define EE_SFML_COMPATIBILITY_H

#include <SFML/Config.hpp>

#if SFML_VERSION_MAJOR != 2
#error unhandled sfml version.
#endif

#include <SFML/Graphics/RenderTarget.hpp>

#if SFML_VERSION_MAJOR < 5
#include <SFML/Graphics/RenderTexture.hpp>
#include <SFML/Graphics/RenderWindow.hpp>
#endif

inline void activateRenderTarget(sf::RenderTarget& target, bool active = true)
{
#if SFML_VERSION_MAJOR > 4
    target.setActive(active);
#else
    // SFML 2.4 has setActive on both render texture and window,
    // but it's not on their common ancestor (that change is from 2.5)
    if (auto* as_window = dynamic_cast<sf::RenderWindow *>(&target))
    {
        as_window->setActive(active);
    }
    else if (auto* as_texture = dynamic_cast<sf::RenderTexture *>(&target))
    {
        as_texture->setActive(active);
    }
#endif // SFML_VERSION_MAJOR > 4
}
#endif // EE_SFML_COMPATIBLITY_H
