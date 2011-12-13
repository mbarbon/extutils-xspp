#ifndef myinit_h_
#define myinit_h_

// We need to do this so that we have the fake type Dog_Factory
// available for mapping it with a different typemap. This is
// a nasty workaround, nothing more.
// We define a typemap for Dog_Factory* which has the class
// hardcoded. See xsp/mytype.map.
class Dog;
typedef Dog Dog_Factory;

#endif
