using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using HTC.UnityPlugin.Vive;
using HTC.UnityPlugin.Utility;


public class Position_Script : MonoBehaviour
{
    public static Vector3 v;
    Vector3 v0;
    //// Start is called before the first frame update
    void awake()
    {
        v0 = VivePose.GetPoseEx(HandRole.RightHand).pos; // last known position of left controller
    }
    // Update is called once per frame
    void Update()
    {
        RigidPose pose = VivePose.GetPoseEx(HandRole.RightHand);
        //RigidPose pose2 = VivePose.GetPoseEx(TrackerRole.Tracker1);

        //print(pose1.pos.x + " " + pose1.pos.y + " " + pose1.pos.z);
        //set transform to the mid point between them
        //if (VivePose.IsValidEx(HandRole.RightHand) && VivePose.IsValidEx(TrackerRole.Tracker1))
        //{
        //    transform.localPosition = Vector3.Lerp(pose1.pos, pose2.pos, 0.5f);
        //    transform.localRotation = Quaternion.Lerp(pose1.rot, pose2.rot, 0.5f);
        //}
        if (ViveInput.GetPressEx(HandRole.RightHand, ControllerButton.Trigger))
        {
            v = pose.pos-v0 ;
        }
        //print(v);

    }
}
