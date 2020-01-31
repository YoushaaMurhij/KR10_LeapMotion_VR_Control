using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace ViveHandTracking {

class ModelRenderer : MonoBehaviour {
  public bool IsLeft = false;
  [Range(0.1f, 1.0f)]
  public float Smoothness = 0.1f;
  public GameObject Hand = null;
  public Transform[] Nodes;

  private Vector3 m_NewPos;
  private Quaternion m_NewRot;
  private Vector3 wristYDir, wristXDir, wristZDir;
  private Vector3 MwristYDir, MwristXDir, MwristZDir;
  private List<Quaternion> q1 = new List<Quaternion>();
  private List<Quaternion> q2 = new List<Quaternion>();
  private List<Quaternion> q3 = new List<Quaternion>();

  void Awake() {
    m_NewPos = Vector3.zero;
    m_NewRot = Quaternion.identity;
    for (int i = 0; i < 5; i++) {
      int startIndex = i * 4 + 1;
      q1.Add(Nodes[startIndex].localRotation);
      q2.Add(Nodes[startIndex + 1].localRotation);
      q3.Add(Nodes[startIndex + 2].localRotation);
    }
    Hand.SetActive(false);
  }

  IEnumerator Start() {
    while (GestureProvider.Status == GestureStatus.NotStarted)
      yield return null;
    if (!GestureProvider.HaveSkeleton)
      this.enabled = false;
  }

  void Update() {
    transform.position = Vector3.Lerp(transform.position, m_NewPos, Smoothness);
    transform.rotation = Quaternion.Slerp(transform.rotation, m_NewRot, Smoothness);
    if (!GestureProvider.UpdatedInThisFrame)
      return;

    GestureResult result = IsLeft ? GestureProvider.LeftHand : GestureProvider.RightHand;
    if (result == null) {
      Hand.SetActive(false);
      return;
    }
    Hand.SetActive(true);

    Vector3 _Wrist = result.points[0];
    Vector3 _Index = result.points[5];
    Vector3 _Middle = result.points[9];
    Vector3 _ring = result.points[13];
    Vector3 _zd = (result.points[5] + result.points[13]) / 2;
    m_NewPos = _Wrist;
    Vector3 _MidDir = _Middle - _Wrist;
    Vector3 _ringDir = _ring - _Wrist;
    Vector3 _IndexDir = _Index - _Wrist;
    Vector3 _zdDir = -_zd - _Wrist;
    Vector3 _PalmDir = Vector3.Cross(_IndexDir, _ringDir);

    Vector3 _UpDir = Vector3.Cross(_ringDir, _PalmDir);
    _MidDir = Quaternion.AngleAxis(7, _PalmDir) * _MidDir;
    m_NewRot = Quaternion.LookRotation(_MidDir, _UpDir);
    if ((result.points[13] - result.points[5]).magnitude == 0)
      return;

    for (int i = 0; i < 5; ++i)
      SetFingerAngle(result, i);
  }

  /// fingerIndex is ranged from 0 to 4, i.e. from thumb to pinky
  private void SetFingerAngle(GestureResult hand, int fingerIndex) {
    int startIndex = fingerIndex * 4 + 1;
    Vector3 root = hand.points[startIndex];
    Vector3 joint1 = hand.points[startIndex + 1];
    Vector3 joint2 = hand.points[startIndex + 2];
    Vector3 top = hand.points[startIndex + 3];

    Vector3 vec0 = root - hand.points[0];
    Vector3 vec1 = joint1 - root;
    Vector3 vec2 = joint2 - joint1;
    Vector3 vec3 = top - joint2;

    if (vec0.magnitude == 0 || vec1.magnitude == 0 || vec2.magnitude == 0 || vec3.magnitude == 0)
      return;

    Nodes[startIndex].localRotation = q1[fingerIndex];
    Nodes[startIndex + 1].localRotation = q2[fingerIndex];
    Nodes[startIndex + 2].localRotation = q3[fingerIndex];
    if ((hand.points[9] - hand.points[0]).magnitude == 0)
      return;

    float k = (Nodes[9].position - Nodes[0].position).magnitude / (hand.points[9] - hand.points[0]).magnitude;
    float IdealLength = k * (hand.points[startIndex] - hand.points[0]).magnitude;
    Nodes[startIndex].position = Nodes[0].position + (Nodes[startIndex].position -
                                 Nodes[0].position).normalized * IdealLength;

    Vector3 vec5 = Nodes[startIndex].position - Nodes[0].position;
    Vector3 vec9 = Vector3.zero;

    setAxis(hand);
    float angle0 = 0.0f;

    if (fingerIndex == 0 || fingerIndex == 2 || fingerIndex == 4) {
      if (Vector3.Cross(wristXDir, vec0).magnitude != 0.0f) {

        calculateModelPos(wristXDir, vec0, MwristXDir, vec5, out angle0, out vec9);

        Nodes[startIndex].position = Nodes[0].position + vec9.normalized * (Nodes[startIndex].position -
                                     Nodes[0].position).magnitude;
      }
    }

    if (Vector3.Cross(vec0, vec1).magnitude != 0) {
      setRotation(vec0, vec1, angle0, vec9, startIndex,  hand);
      if (fingerIndex != 0)
        Nodes[startIndex].localEulerAngles = new Vector3(0, Nodes[startIndex].localEulerAngles.y,
            Nodes[startIndex].localEulerAngles.z);
    } else
      Nodes[startIndex].localRotation = q1[fingerIndex];

    if (Vector3.Cross(vec1, vec2).magnitude != 0) {
      setRotation(vec1, vec2, angle0, vec9, startIndex + 1,  hand);
      Nodes[startIndex + 1].localEulerAngles = new Vector3(0, Nodes[startIndex + 1].localEulerAngles.y,
          Nodes[startIndex + 1].localEulerAngles.z);
    } else
      Nodes[startIndex + 1].localRotation = q2[fingerIndex];

    if (Vector3.Cross(vec2, vec3).magnitude != 0) {
      setRotation(vec2, vec3, angle0, vec9, startIndex + 2,  hand);
      Nodes[startIndex + 2].localEulerAngles = new Vector3(0, Nodes[startIndex + 2].localEulerAngles.y,
          Nodes[startIndex + 2].localEulerAngles.z);
    } else
      Nodes[startIndex + 2].localRotation = q3[fingerIndex];
  }

  float[] GaussFunction(float[,] a, int n) {
    int i, j, k;
    int rank, columm;
    float temp, l, s;
    float[] x = new float[n];
    for (i = 0; i <= n - 2; i++) {
      rank = i;
      columm = i;
      for (j = i + 1; j <= n - 1; j++)
        if (a[j, i] > a[i, i]) {
          rank = j;
          columm = i;
        }
      for (k = 0; k <= n; k++) {
        temp = a[i, k];
        a[i, k] = a[rank, k];
        a[rank, k] = temp;
      }
      for (j = i + 1; j <= n - 1; j++) {
        l = a[j, i] / a[i, i];
        for (k = i; k <= n; k++)
          a[j, k] = a[j, k] - l * a[i, k];
      }
    }
    x[n - 1] = a[n - 1, n] / a[n - 1, n - 1];
    for (i = n - 2; i >= 0; i--) {
      s = 0;
      for (j = i + 1; j <= n - 1; j++)
        s = s + a[i, j] * x[j];
      x[i] = (a[i, n] - s) / a[i, i];
    }
    return x;
  }

  void calculateModelPos(Vector3 v0, Vector3 v1, Vector3 Mv0, Vector3 Mv1, out float angle, out Vector3 vec) {
    angle = SignedAngle(v0, v1);
    vec = Vector3.Cross(v0, v1).normalized;
    float a1 = Vector3.Dot(wristXDir, vec);
    float a2 = Vector3.Dot(wristYDir, vec);
    float a3 = Vector3.Dot(wristZDir, vec);
    float[,] arr = { {  MwristXDir.x, MwristXDir.y, MwristXDir.z, a1  },
      { MwristYDir.x, MwristYDir.y, MwristYDir.z, a2  },
      { MwristZDir.x, MwristZDir.y, MwristZDir.z, a3},
    };
    float[] result = new float[3];
    result = GaussFunction(arr, 3);

    vec = new Vector3(result[0], result[1], result[2]);
    vec = Quaternion.AngleAxis(angle, vec) * Mv0;
    angle = SignedAngle(Mv1, vec);
  }

  void setAxis(GestureResult hand) {
    wristXDir = (-Vector3.Cross(hand.points[5] - hand.points[0], hand.points[13] - hand.points[0])).normalized;
    wristYDir = (Vector3.Cross(wristXDir, (hand.points[13] + hand.points[5]) / 2 - hand.points[0])).normalized;
    wristZDir = ((hand.points[13] + hand.points[5]) / 2 - hand.points[0]).normalized;
    MwristXDir = (-Vector3.Cross(Nodes[5].position - Nodes[0].position,
                                 Nodes[13].position - Nodes[0].position)).normalized;
    MwristYDir = (Vector3.Cross(MwristXDir,
                                (Nodes[13].position + Nodes[5].position) / 2 - Nodes[0].position)).normalized;
    MwristZDir = ((Nodes[13].position + Nodes[5].position) / 2 - Nodes[0].position).normalized;
  }

  void setRotation(Vector3 vec0, Vector3 vec1, float angle0, Vector3 vec9, int joint,
                   GestureResult hand) {
    Vector3 vecM0 = Vector3.zero;
    Vector3 vecM1 = Vector3.zero;
    if (joint == 1 || joint == 5 || joint == 9 || joint == 13 || joint == 17)
      vecM0 = Nodes[joint].position - Nodes[0].position;
    else
      vecM0 = Nodes[joint].position - Nodes[joint - 1].position;
    vecM1 = Nodes[joint + 1].position - Nodes[joint].position;

    calculateModelPos(vec0, vec1, vecM0, vecM1, out angle0, out vec9);
    if (joint / 4 > 0) {
      float TempAngle1 = Vector3.Angle(vec9, Nodes[joint - 3].position - Nodes[joint - 4].position);
      float TempAngle2 = Vector3.Angle(vec1, hand.points[joint - 3] - hand.points[joint - 4]);
      if (Mathf.Abs(TempAngle1 - TempAngle2) > 0.5f) {
        vec9 = Quaternion.AngleAxis(-Mathf.Abs(TempAngle1 - TempAngle2), Vector3.Cross(vec9,
                                    Nodes[joint - 3].position - Nodes[joint - 4].position)) * vec9;
        angle0 = SignedAngle(vecM1, vec9);
      }
    }

    Nodes[joint].rotation = Quaternion.AngleAxis(angle0, Vector3.Cross(vecM1, vec9)) * Nodes[joint].rotation;
  }

  private static float SignedAngle(Vector3 v1, Vector3 v2) {
#if UNITY_2017_1_OR_NEWER
    return Vector3.SignedAngle(v1, v2, Vector3.Cross(v1, v2));
#else
    return Vector3.Angle(v1, v2);
#endif
  }
}

}
