using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Axis6_Rotator : MonoBehaviour
{
    private double theta_6;
    private double d_theta6;
    internal void Start()
    {
        theta_6 = 0;
    }
    internal void Update()
    {
        theta_6 = MainCode.alpha6;
        theta_6 = -1 * theta_6;
        double ACT;
        if (theta_6 >= -350 && theta_6 <= 350)
        {
            if (transform.localEulerAngles.z > 180)
            {
                ACT = transform.localEulerAngles.z - 360;
            }
            else
            {
                ACT = transform.localEulerAngles.z;
            }
            d_theta6 = theta_6 - ACT;
            Quaternion originalRot = transform.rotation;
            transform.rotation = originalRot * Quaternion.AngleAxis((float)d_theta6, Vector3.forward);
        }
    }
}
