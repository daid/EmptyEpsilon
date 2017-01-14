#ifndef FEATURE_DEFS_H
#define FEATURE_DEFS_H

// Android doesn't bundle 3D models or music.
#ifndef FEATURE_3D_RENDERING

# ifdef __ANDROID__
#  define FEATURE_3D_RENDERING 0
# else
#  define FEATURE_3D_RENDERING 1
# endif//__ANDROID__

#endif

#define DISTANCE_UNIT_1K "u"

#endif//FEATURE_DEFS_H
