# KR10_LeapMotion_VR_Control
 Online/Offline Control of KUKA-KR10 using Leapmotion sensor and VR controllers inside Unity Environment 

# In this repo:
A development and implementation of a VR application controlling an industrial manipulator was done to improve the usability of this manipulator and enable the interaction between the user and the robot and its workspace features

* Hardware: 
Our Hardware part included an industrial manipulator connected to a PC using TCP/IP connection. In addition to AR/VR supported headset and controllers with an IR stereo camera (Leapmotion) as an option.
* Software:
A Unity3D VR application containing the 3D model of the manipulator connected with the real robot and VR instruments.
 
 ![GitHub 3D model of the KUKA Manipulator in Unity3D](/img1.jpg)

# Data input methods
1. IR stereo camera sensor (Leapmotion) : captures both hands movements in real time.
2. AR/VR sensors ( HTC VIVE pro instruments) : captures head and controllers movements in real time.

 ![GitHub 3D model of the KUKA Manipulator in Unity3D](/gif1.gif)
 
# System Procedure:
* Leapmotion: hand movements read as position coordinates  
* VR : the head and controllers movements  read as 6DOF data.
* Data Filtering is sometimes required in this stage to remove noise and outliers. (Complementary filter was used).
* 6DOF data of the controllers is mapped to the position and orientation of the industrial robot’s end effector in the application.
* Inverse Kinematics is used to calculate the generalized parameters of the virtual robot.
* Generalized parameters are sent to the joints of the real robot.

 ![GitHub LeapMotion Data Visualization](/gif2.gif)





