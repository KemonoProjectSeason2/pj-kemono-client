using UnityEngine;

namespace Player
{
    /// <summary>
    /// �v���C���[�̓��͂𐧌䂷��C���^�[�t�F�[�X
    /// </summary>
    public interface IPlayerInputProvider 
    {
        /// <summary>
        /// �v���C���[�̓�������
        /// </summary>
        Vector3 MoveDirection { get; }
         
        /// <summary>
        /// �J�����̌�������
        /// </summary>
        Vector2 LookDirection { get; }

        /// <summary>
        /// �W�����v�����ǂ������肷��t���O
        /// </summary>
        bool IsJump { get; set; }

        /// <summary>
        /// �_�b�V���������肷��t���O
        /// </summary>
        bool IsSprint { get; }
        
        /// <summary>
        /// ���[�U�[���͂��u�L�[�{�[�h�}�E�X���́v���ǂ������肷��t���O
        /// </summary>
        bool IsCurrentDeviceMouse { get; }
    }
}

