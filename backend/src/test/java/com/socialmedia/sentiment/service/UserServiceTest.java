package com.socialmedia.sentiment.service;

import com.socialmedia.sentiment.entity.User;
import com.socialmedia.sentiment.mapper.UserMapper;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.security.crypto.password.PasswordEncoder;

import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.Mockito.*;

/**
 * 用户服务单元测试
 */
@ExtendWith(MockitoExtension.class)
class UserServiceTest {

    @Mock
    private UserMapper userMapper;

    @Mock
    private PasswordEncoder passwordEncoder;

    @InjectMocks
    private UserService userService;

    private User testUser;

    @BeforeEach
    void setUp() {
        testUser = new User();
        testUser.setUserId(1L);
        testUser.setUsername("testuser");
        testUser.setEmail("test@example.com");
        testUser.setPassword("encodedPassword");
        testUser.setStatus("ACTIVE");
        testUser.setRole("USER");
    }

    @Test
    void testRegisterUser_Success() {
        // Given
        when(userMapper.findByUsername(anyString())).thenReturn(null);
        when(userMapper.findByEmail(anyString())).thenReturn(null);
        when(passwordEncoder.encode(anyString())).thenReturn("encodedPassword");
        when(userMapper.insert(any(User.class))).thenReturn(1);

        // When
        User result = userService.registerUser("testuser", "test@example.com", "password");

        // Then
        assertNotNull(result);
        assertEquals("testuser", result.getUsername());
        assertEquals("test@example.com", result.getEmail());
        assertEquals("ACTIVE", result.getStatus());
        verify(userMapper, times(1)).insert(any(User.class));
        verify(passwordEncoder, times(1)).encode("password");
    }

    @Test
    void testRegisterUser_UsernameExists() {
        // Given
        when(userMapper.findByUsername(anyString())).thenReturn(testUser);

        // When & Then
        assertThrows(RuntimeException.class, () -> {
            userService.registerUser("testuser", "test2@example.com", "password");
        });
        verify(userMapper, never()).insert(any(User.class));
    }

    @Test
    void testRegisterUser_EmailExists() {
        // Given
        when(userMapper.findByUsername(anyString())).thenReturn(null);
        when(userMapper.findByEmail(anyString())).thenReturn(testUser);

        // When & Then
        assertThrows(RuntimeException.class, () -> {
            userService.registerUser("testuser2", "test@example.com", "password");
        });
        verify(userMapper, never()).insert(any(User.class));
    }

    @Test
    void testLoginUser_Success() {
        // Given
        when(userMapper.findByUsername(anyString())).thenReturn(testUser);
        when(passwordEncoder.matches(anyString(), anyString())).thenReturn(true);

        // When
        User result = userService.loginUser("testuser", "password");

        // Then
        assertNotNull(result);
        assertEquals("testuser", result.getUsername());
        verify(userMapper, times(1)).findByUsername("testuser");
        verify(passwordEncoder, times(1)).matches("password", "encodedPassword");
    }

    @Test
    void testLoginUser_UserNotFound() {
        // Given
        when(userMapper.findByUsername(anyString())).thenReturn(null);

        // When & Then
        assertThrows(RuntimeException.class, () -> {
            userService.loginUser("nonexistent", "password");
        });
    }

    @Test
    void testLoginUser_WrongPassword() {
        // Given
        when(userMapper.findByUsername(anyString())).thenReturn(testUser);
        when(passwordEncoder.matches(anyString(), anyString())).thenReturn(false);

        // When & Then
        assertThrows(RuntimeException.class, () -> {
            userService.loginUser("testuser", "wrongpassword");
        });
    }

    @Test
    void testFindById_Success() {
        // Given
        when(userMapper.findById(1L)).thenReturn(Optional.of(testUser));

        // When
        Optional<User> result = userService.findById(1L);

        // Then
        assertTrue(result.isPresent());
        assertEquals(testUser, result.get());
        verify(userMapper, times(1)).findById(1L);
    }

    @Test
    void testFindById_NotFound() {
        // Given
        when(userMapper.findById(999L)).thenReturn(Optional.empty());

        // When
        Optional<User> result = userService.findById(999L);

        // Then
        assertFalse(result.isPresent());
        verify(userMapper, times(1)).findById(999L);
    }

    @Test
    void testUpdateUserStatus() {
        // Given
        when(userMapper.findById(1L)).thenReturn(Optional.of(testUser));
        when(userMapper.updateStatus(1L, "DISABLED")).thenReturn(1);

        // When
        userService.updateUserStatus(1L, "DISABLED");

        // Then
        verify(userMapper, times(1)).updateStatus(1L, "DISABLED");
    }

    @Test
    void testDeleteUser() {
        // Given
        when(userMapper.deleteById(1L)).thenReturn(1);

        // When
        userService.deleteUser(1L);

        // Then
        verify(userMapper, times(1)).deleteById(1L);
    }
}
