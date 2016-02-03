#ifndef LANGUAGE_H
#define LANGUAGE_H

#include "engine.h"

/*!
 * \brief Support for internationalization
 */

extern bool inhibit_locale;

//append a translation context to a message to separate different translation of a same word
string pgettext(string context, string message);

#endif
