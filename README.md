VirtualDanceFloor
=================

This project is a deliverable for Aalto University course Experimental User Interfaces.

VirtualDanceFloor is, as the name suggests, a party in a virtual 3D dance floor setting. By utilizing the Microsoft Kinect sensor, users can control their avatars in the virtual world by moving their body in the real world. 

There are some gestures to interact with the scene, like for starting up the party mode one has to make a "Saturday Night Fever" pose, and standing still with hands on sides will stop the party.

The Kinect sensor provides a way of using the whole body as a controller. The user does not need any devices like hand-held controllers or keyboards to interact. Rather the system can recognize the user's stature, hand and foot positions and so on in 3D space, and this *natural interaction* forms the basis for interacting with the system. Existing Kinect libraries, like OpenNI, provide several skeleton points, which can be used for mapping an avatar to match the user's movements. 


Design principles
=================

### Interaction design

VirtualDanceFloor creates colored stick figure -like avatars for each user in a three-dimensional room. As the users move around in the real world, their avatars move around in the virtual world, matching their movement and body positions. 

To start the party mode, one of the users has to show the willingness to party: he/she will have to assume a Saturday Night Fever pose, with the right hand up and left hand down. When the party mode is on, users need to keep moving. In other words, if all users have their hands down for a while, the party mode shuts down. While in party mode, there are a couple of gestures for special effects. The *hadouken* is done by raising hands to shoulder level, keeping them close to each other. Hadouken triggers a strobe light effect in the virtual dance floor. Performing a hand wave makes the users' hands emit colored particles that float down, for an even more impressive party.

All the gestures and poses mentioned are very natural ways of interacting with the world when compared to pushing buttons or touching screens.

### Software architecture

This application is built upon existing Processing sketch called "Olkkari" from Studio 4 course (2011). We used all the existing functionality (Navigatable 3D-model, lighting effects and sounds.) and developed on top of that gesture based event triggering the and virtual dancers. In addition we also created a new particle effect to make the movement of the dancers more exciting. 

The application core architecture follows the basic processing sketch design pattern where the setup()-function first takes care of initializing the application state and then the draw-function() is being repeatedly executed until the program is terminated. In addition to the main class we also use 10 helper classes: 5 new classes for gesture recognition and 3 existing classes and 2 new classes for visual effects. The new classes include: Particle, ParticleSystem, HadoukenDetector, PushDetector, SaturdayNightFeverDetector and StaticGestureDetector.

We interfaced the Kinect Sensor with open source 3D-sensor SDK called OpenNI. Because OpenNI is a C++ library, we also used an open source Processing wrapper called SimpleOpenNI. The SimpleOpenNI enabled us to receive preprocessed data such as a 15-joint skeleton in addition to raw depth field and camera images. The OpenNI has internal gesture recognition feature, but because it lacked the desired level of robustness we decided to implement most of the gesture detecting ourselves.   

Gesture recognition classes utilize joint position information from the OpenNi provided skeleton to make simple assumptions about the relative locations of the body parts. For example the SaturdayNightFever-gesture gets triggered when the left hand-joint is below the hip-joint and the right hand-joint is over the head-joint (measured on the y-axis). Because all gestures are checked every frame by a simple method call, most of them will be triggered instantly. However for the StaticGesture (hands below torso) we also added a 30-frame time interval to slow down the detection.
