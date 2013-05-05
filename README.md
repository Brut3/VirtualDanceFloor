VirtualDanceFloor
=================

This project is a deliverable for Aalto University course Experimental User Interfaces.

VirtualDanceFloor is, as the name suggests, a party in a virtual 3D dance floor setting. 
By utilizing the Microsoft Kinect sensor, users can control their avatars in the 
virtual world by moving their body in the real world. 

There are some gestures to interact with the scene, like for starting up the party mode one 
has to make a "Saturday Night Fever" pose, and standing still with hands on sides will stop the party.


Design principles
=================

### Interaction design


### Software architecture

This application is built upon existing Processing sketch called "Olkkari" from Studio 4 course (2011). We used all the existing functionality (Navigatable 3D-model, lighting effects and sounds.) and developed on top of that gesture based event triggering the and the virtual dancers. In addition we also created a new particle effect to make the movement of the dancers more exciting. 
The application core architecture follows the basic processing sketch design pattern where the setup()-function first takes care of initialisig the application state and then the draw-function() is being repeatedly excecuted until the program is terminated. In addition to the main class we also use 10 helper classes: 5 new classes for gesture recognition and 3 existing classes and 2 new classes for visual effets. The new classes include: Particle, ParticleSystem, HadoukenDetector, PushDetector, SaturdayNightFeverDetector and StaticGestureDetector.

