using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Axis4_Rotator : MonoBehaviour
{
    private double theta_4;
    private double d_theta4;
    internal void Start()
    {
        theta_4 = 0;
    }
    internal void Update()
    {
        theta_4 = MainCode.alpha4;
        theta_4 = -1 * theta_4;
        double ACT;
        if (theta_4 >= -185 && theta_4 <= 185)
        {
            if (transform.localEulerAngles.z > 180)
            {
                ACT = transform.localEulerAngles.z - 360;
            }
            else
            {
                ACT = transform.localEulerAngles.z;
            }
            d_theta4 = theta_4 - ACT;
            Quaternion originalRot = transform.rotation;
            transform.rotation = originalRot * Quaternion.AngleAxis((float)d_theta4, Vector3.forward);
        }
    }
}
