using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System;
using System.Linq;
using System.Text;
using System.Threading;
using Leap;
using Leap.Unity;
using Leap.Unity.Attributes;
public class Variables
{
    public static double[] xyz_ref;
    public static Mat target_pose;
    public static RoboDK.Item ROBOT;
}
public class MainCode : MonoBehaviour {
    public LeapServiceProvider provider;
    double x, y, z, X=0, Y=0, Z=0;
    double[] joints;
    double[] home_joints = { 0, -45, 45, 1, 45, 5 }; // home joints, in deg
    public static int alpha1=0, alpha2=-90, alpha3=90, alpha4=0, alpha5=0, alpha6=0;
    public bool LeapBOOL = false;
    public bool ContBOOL = true;
    public bool HandBOOL = true;
    public bool BO2 = true;
    int Factor_VR = 70;
    int Factor_LM = 400; //400
    void Start () {
        RoboDK RDK = new RoboDK();
        Variables.ROBOT = RDK.ItemUserPick("Select a robot", RoboDK.ITEM_TYPE_ROBOT);
        // if (Variables.ROBOT.Connect())
        // {
        //     RDK.setRunMode(RoboDK.RUNMODE_RUN_ROBOT);
        // }
        // else
        // {
        //     RDK.setRunMode(RoboDK.RUNMODE_SIMULATE);
        // }
        RDK.setRunMode(RoboDK.RUNMODE_SIMULATE);
        //Variables.ROBOT.MoveJ(home_joints);
        Mat frame = Variables.ROBOT.PoseFrame();
        //Mat tool = Variables.ROBOT.PoseTool();
        Mat pose_ref = Variables.ROBOT.Pose();
        Variables.target_pose = Variables.ROBOT.Pose();
        Variables.xyz_ref = Variables.target_pose.Pos();
        Variables.ROBOT.MoveJ(pose_ref);
        Variables.ROBOT.setPoseFrame(frame);  // set the reference frame
        //Variables.ROBOT.setPoseTool(tool);    // set the tool frame: important for Online Programming
        Variables.ROBOT.setSpeed(500);        // Set Speed to 100 mm/s
        Variables.ROBOT.setZoneData(5);       // set the rounding instruction 
        //Variables.ROBOT.MoveL(pose_ref);
    }
    void Update () {
        if (LeapBOOL)
        {
            Frame frame = provider.CurrentFrame;
            if (frame != null)
            {
                if (frame.Hands.Count > 0)
                {
                    Debug.Log("Test");
                    Hand hand = frame.Hands[0];
                    X = hand.PalmPosition.z;
                    Y = hand.PalmPosition.x;
                    Z = hand.PalmPosition.y;
                }
                x = Variables.xyz_ref[0] + X * Factor_LM;
                y = Variables.xyz_ref[1] - Y * Factor_LM;
                z = Variables.xyz_ref[2] + Z * Factor_LM;
                //Vector3 handPosition = hand.PalmPosition.ToVector3();
            }
        }
        else if (ContBOOL)
        {
            x = Variables.xyz_ref[0] + Position_Script.v.z * Factor_VR;
            y = Variables.xyz_ref[1] - Position_Script.v.x * Factor_VR;
            z = Variables.xyz_ref[2] + Position_Script.v.y * Factor_VR;
        }

        Variables.target_pose.setPos(x, y, z);
            //Variables.ROBOT.MoveL(Variables.target_pose);
            joints = Variables.ROBOT.Joints();
            alpha1 = (int)joints[0];
            alpha2 = (int)joints[1];
            alpha3 = (int)joints[2];
            alpha4 = (int)joints[3];
            alpha5 = (int)joints[4];
            alpha6 = (int)joints[5];
    }
    //void OnGUI()
    //{
    //    if (GUI.Button(new Rect(25, 25, 150, 30), "LeapMotion connect"))
    //    {
    //        LeapBOOL = true;
    //    }
    //    if (GUI.Button(new Rect(25, 60, 150, 30), "LeapMotion disconnect"))
    //    {
    //        // This code is executed when the Button is clicked
    //        LeapBOOL = false;
    //    }
    //}
}