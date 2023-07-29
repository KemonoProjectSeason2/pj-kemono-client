using UnityEngine;

namespace Player
{
    /// <summary>
    /// プレイヤーの入力を制御するインターフェース
    /// </summary>
    public interface IPlayerInputProvider 
    {
        /// <summary>
        /// プレイヤーの動く方向
        /// </summary>
        Vector3 MoveDirection { get; }
         
        /// <summary>
        /// カメラの向く方向
        /// </summary>
        Vector2 LookDirection { get; }

        /// <summary>
        /// ジャンプ中かどうか判定するフラグ
        /// </summary>
        bool IsJump { get; set; }

        /// <summary>
        /// ダッシュ中か判定するフラグ
        /// </summary>
        bool IsSprint { get; }
        
        /// <summary>
        /// ユーザー入力が「キーボードマウス入力」かどうか判定するフラグ
        /// </summary>
        bool IsCurrentDeviceMouse { get; }
    }
}

