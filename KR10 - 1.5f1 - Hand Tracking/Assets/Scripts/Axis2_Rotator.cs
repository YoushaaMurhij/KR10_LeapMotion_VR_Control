using System.Collections;
using System.Collections.Generic;
using UnityEngine;
public class Axis2_Rotator : MonoBehaviour
{
    private double theta_2;
    private double d_theta2;
    void Start()
    {
        theta_2 = -45;
    }
    void Update()
    {
        theta_2 = MainCode.alpha2;
        theta_2 = -1 * theta_2;
        double ACT;
        if (theta_2 >= -45 && theta_2 <= 190)
        {
            //if (transform.localEulerAngles.x > 180)
            //{
            //    ACT = transform.localEulerAngles.x - 360;
            //}
            //else
            //{
            //    ACT = transform.localEulerAngles.x;
            //}
            d_theta2 = theta_2 - transform.localEulerAngles.x;
            Quaternion originalRot = transform.rotation;
            //transform.rotation = originalRot * Quaternion.AngleAxis((float)d_theta2, Vector3.left);


            // Rotate the cube by converting the angles into a quaternion.
            Quaternion target = Quaternion.Euler(-1*(float)d_theta2, 0, 0);
            // Dampen towards the target rotation
            //transform.rotation = originalRot * Quaternion.Slerp(transform.rotation, target, 1);
            transform.localEulerAngles = new Vector3(-1 * (float)theta_2-180, 180, 0);
                                 
        }
    }
}
