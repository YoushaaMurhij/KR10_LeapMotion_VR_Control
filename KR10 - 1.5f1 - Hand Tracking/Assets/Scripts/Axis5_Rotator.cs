using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Axis5_Rotator : MonoBehaviour
{
    private double theta_5;
    private double d_theta5;
    internal void Start()
    {
        theta_5 = 0;
    }
    internal void Update()
    {
        theta_5 = MainCode.alpha5;
        //double ACT;
        if (theta_5 >= -120 && theta_5 <= 120)
        {
            //if (transform.localEulerAngles.x > 180)
            //{
            //    ACT = transform.localEulerAngles.x - 360;
            //}
            //else
            //{
            //    ACT = transform.localEulerAngles.x;
            //}
            d_theta5 = theta_5 - transform.localEulerAngles.x;

            Quaternion originalRot = transform.rotation;
            //transform.rotation = originalRot * Quaternion.AngleAxis((float)d_theta5, Vector3.right);

            // Rotate the cube by converting the angles into a quaternion.
            //Quaternion target = Quaternion.Euler((float)d_theta5, 0, 0);
            // Dampen towards the target rotation
            //transform.rotation = originalRot* Quaternion.Slerp(transform.rotation, target, 1);

            transform.localEulerAngles = new Vector3((float)theta_5, 180, 0);

        }
    }
}
