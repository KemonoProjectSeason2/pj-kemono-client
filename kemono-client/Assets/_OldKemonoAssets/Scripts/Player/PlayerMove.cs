using UnityEngine;

namespace Player
{
    /// <summary>
    /// プレイヤーの動きを制御するクラス.
    /// </summary>
    public class PlayerMove : MonoBehaviour
    {
        [SerializeField] 
        private CharacterController characterController;

        [SerializeField] 
        private PlayerMoveParameterScriptableObject playerMoveParameter;
        
        private IPlayerInputProvider playerInputProvider;

        private float verticalVelocity;
        
        private float speed;

        /// <summary>
        ///　地面判定するフラグ
        /// </summary>
        private bool isGrounded;

        private void Start()
        {
            //TODO　ここの参照の取り方は変更する
            TryGetComponent(out playerInputProvider);
        }

        private void Update()
        {
            CheckGround();
            CalculateVerticalVelocity();
            Move();
        }


        /// <summary>
        /// プレイヤーの最終的な動きを制御する関数
        /// </summary>
        private void Move()
        {
            float targetSpeed = playerInputProvider.IsSprint ? playerMoveParameter.SprintSpeed : playerMoveParameter.MoveSpeed;

            if (playerInputProvider.MoveDirection.magnitude == 0f)
            {
                targetSpeed = 0f;
            }

            float currentHorizontalSpeed = new Vector3(characterController.velocity.x, 0f, characterController.velocity.z).magnitude;
            float speedOffset = 0.1f;
            float inputMagnitude = playerInputProvider.MoveDirection.magnitude;

            //加速or減速処理
            if (currentHorizontalSpeed < targetSpeed - speedOffset ||
                currentHorizontalSpeed > targetSpeed + speedOffset)
            {
                speed = Mathf.Lerp(currentHorizontalSpeed, targetSpeed * inputMagnitude,
                    Time.deltaTime * playerMoveParameter.SpeedChangeRate);
                
                //速度を小数点3桁以下で丸める
                speed = Mathf.Round(speed * 1000f) / 1000f;
            }
            else
            {
                speed = targetSpeed;
            }
            
            characterController.Move( playerInputProvider.MoveDirection.normalized * speed * Time.deltaTime 
                                      + new Vector3(0f, verticalVelocity, 0f) * Time.deltaTime);
        }

        /// <summary>
        /// verticalVelocityを計算する関数.
        /// 主にジャンプ時の制御, 落下運動の制御に使用する.
        /// </summary>
        private void CalculateVerticalVelocity()
        {
            if (isGrounded)
            {
                if (verticalVelocity < 0f)
                {
                    verticalVelocity = -2f;
                }
              
                if (playerInputProvider.IsJump)
                {
                    verticalVelocity = Mathf.Sqrt(playerMoveParameter.TargetJumpHeight * -2f * playerMoveParameter.GravityPower);
                }
            }
            else
            {
                verticalVelocity += playerMoveParameter.GravityPower * Time.deltaTime;
                playerInputProvider.IsJump = false;
            }
        }

        /// <summary>
        /// 地面との設置判定を行う関数.
        /// </summary>
        private void CheckGround()
        {
            Vector3 spherePosition = new Vector3(transform.position.x,
                transform.position.y - playerMoveParameter.GroundOffset, transform.position.z);
            
            isGrounded = Physics.CheckSphere(spherePosition, playerMoveParameter.GroundCheckSphereRadius,
                playerMoveParameter.GroundLayers);
        }
    }
}