using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Axis3_Rotator : MonoBehaviour {

    private double theta_3;
    private double d_theta3;

    internal void Start()
    {
        theta_3 = 90;
    }
    internal void Update()
    {
        theta_3 = MainCode.alpha3;
        //double ACT;
        if (theta_3 >= -120 && theta_3 <= 156)
        {
            //if (transform.localEulerAngles.x > 180)
            //{
            //    ACT = transform.localEulerAngles.x - 360;
            //}
            //else
            //{
            //    ACT = transform.localEulerAngles.x;
            //}
            d_theta3 = theta_3 - transform.localEulerAngles.x;

            Quaternion originalRot = transform.rotation;
            //transform.rotation = originalRot * Quaternion.AngleAxis((float)d_theta3, Vector3.right);


            // Rotate the cube by converting the angles into a quaternion.
            Quaternion target = Quaternion.Euler((float)d_theta3-47, 0, 0);
            // Dampen towards the target rotation
            //transform.rotation = originalRot * Quaternion.Slerp(transform.rotation, target, 1);

            transform.localEulerAngles = new Vector3((float)theta_3, 0, 0);

        }
    }
}
