using UnityEngine;
#if ENABLE_INPUT_SYSTEM 
using UnityEngine.InputSystem;
# endif

namespace Player
{
    /// <summary>
    /// プレイヤーの入力を制御するクラス.
    /// Unityが提供するPlayerInputSystemを採用しています
    /// </summary>
#if ENABLE_INPUT_SYSTEM
    [RequireComponent(typeof(PlayerInput))]
#endif
    public sealed class PlayerInputProvider : MonoBehaviour, IPlayerInputProvider
    {

#if ENABLE_INPUT_SYSTEM
        [SerializeField]
        private PlayerInput playerInput;
#endif

        [SerializeField,Header("プレイヤーが動く入力方向")]
		private Vector2 moveDirection;

		[SerializeField,Header("カメラの入力方向")]
		private Vector2 lookDirection;

		[SerializeField,Header("ジャンプボタンが押されたらチェックが入る")]
		private bool isJump;

		[SerializeField,Header("ダッシュボタンが押されたらチェックが入る")]
		private bool isSprint;

		[SerializeField, Header("マウスカーソルをロックするならチェックを入れる（デフォルトはOn）")]
		private bool cursorLocked = true;

		[SerializeField,Header("マウスカーソルでカメラを操作したいならチェックを入れる（デフォルトはOn）")]
		private bool cursorInputForLook = true;
        
        private const string KeyboardMouse = "KeyboardMouse";
        
        #region インターフェースの実装部分
        public Vector3 MoveDirection
        {
            get
            {
                Vector3 dir = new Vector3(moveDirection.x, 0f, moveDirection.y);
                dir = Vector3.ClampMagnitude(dir, 1);
                return dir;
            }
		   
        }

        public Vector2 LookDirection => lookDirection;

        public bool IsJump { get => isJump; set => isJump = value; }

        public bool IsSprint => isSprint;

        public bool IsCurrentDeviceMouse
        {
            get
            {
#if ENABLE_INPUT_SYSTEM
                return playerInput.currentControlScheme == KeyboardMouse;
#else
				return false;
#endif
            }
        }
        #endregion

        #region PlayerInputからSendMessageで受け取る関数
#if ENABLE_INPUT_SYSTEM
        public void OnMove(InputValue value)
        {
            moveDirection = value.Get<Vector2>();
        }

        public void OnLook(InputValue value)
        {
            if (cursorInputForLook)
            {
                lookDirection = value.Get<Vector2>();
            }
        }

        public void OnJump(InputValue value)
        {
            if (isJump) return;
            isJump = value.isPressed;
        }

        public void OnSprint(InputValue value)
        {
            isSprint = value.isPressed;
        }
#endif
        #endregion

        private void OnApplicationFocus(bool hasFocus)
        {
            SetCursorState(cursorLocked);
        }

        private void SetCursorState(bool newState)
        {
            Cursor.lockState = newState ? CursorLockMode.Locked : CursorLockMode.None;
        }
    }
}