using System.Collections;
using System.Collections.Generic;
using UnityEngine;


public class Axis1_Rotator : MonoBehaviour
{
    private double theta_1;
    private double d_theta1;
    public static Quaternion originalRot1;

    void Start()
    {
        theta_1 = 0;
    }
    void Update()
    {
        theta_1 = MainCode.alpha1;
        double ACT;
        if (theta_1 <= 170 && theta_1 >= -170)
        {
            if (transform.localEulerAngles.y>180)
            {
                ACT = transform.localEulerAngles.y - 360;
            }
            else
            {
                ACT = transform.localEulerAngles.y;
            }
            d_theta1 = theta_1 - ACT;
            Quaternion originalRot = transform.rotation;
            transform.rotation = originalRot * Quaternion.AngleAxis((float)d_theta1, Vector3.down);
            originalRot1 = transform.rotation;

        }
    }
}
