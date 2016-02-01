#include <libintl.h>
#include "language.h"
#include "engine.h"

bool inhibit_locale;

string pgettext(string context, string message){
    string original = context + "\004" + message;
    string translation = gettext(original.c_str());

    // if no translation is found, return original
    if (original==translation) return message;
    else return translation;
}
