using UnityEngine;

namespace Player
{
    /// <summary>
    /// プレイヤーの動きを制御するパラメーターをまとめたScriptableObject
    /// </summary>
    [CreateAssetMenu(fileName = "PlayerMoveParameter", menuName = "CreatePlayerMoveParameter", order = 0)]
    public class PlayerMoveParameterScriptableObject : ScriptableObject
    {
        [SerializeField, Header("移動スピード")]
        private float moveSpeed = 3f;

        [SerializeField, Header("ダッシュ時の移動スピード")]
        private float sprintSpeed = 5f;

        [SerializeField, Header("加速or減速時の変化量")]
        private float speedChangeRate = 10.0f;
        
        [SerializeField, Header("ジャンプの高さを設定する")]
        private float targetJumpHeight = 1.2f;

        [SerializeField, Header("プレイヤーにかかる重力。Unityエンジンのデフォルト値は -9.81f")]
        private float gravityPower;

        [SerializeField, Header("地面とのオフセット設定値")] 
        private float groundOffset = - 0.14f;

        [SerializeField, Header("地面との接地判定するスフィアの半径")] 
        private float groundCheckSphereRadius =　0.28f;

        [SerializeField, Header("地面レイヤー")] 
        private LayerMask groundLayers;
        
     
        public float MoveSpeed => moveSpeed;

        public float SprintSpeed => sprintSpeed;

        public float SpeedChangeRate => speedChangeRate;

        public float TargetJumpHeight => targetJumpHeight;

        public float GravityPower => gravityPower;

        public float GroundOffset => groundOffset;

        public float GroundCheckSphereRadius => groundCheckSphereRadius;

        public LayerMask GroundLayers => groundLayers;


    }
}