#ifndef FEATURES_H
#define FEATURES_H

#ifndef FEATURE_3D_RENDERING

# ifdef __ANDROID__
#  define FEATURE_3D_RENDERING 0
# else
#  define FEATURE_3D_RENDERING 1
# endif//__ANDROID__

#endif

#endif//FEATURES_H
