package com.socialmedia.sentiment.service;

import com.socialmedia.sentiment.dto.request.RegisterRequest;
import com.socialmedia.sentiment.entity.User;
import com.socialmedia.sentiment.mapper.UserMapper;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.security.crypto.password.PasswordEncoder;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyLong;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.Mockito.*;

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
        testUser.setPasswordHash("encodedPassword");
        testUser.setStatus("ACTIVE");
        testUser.setRole("USER");
    }

    @Test
    void testRegister_Success() {
        when(userMapper.existsByUsername(anyString())).thenReturn(false);
        when(userMapper.existsByEmail(anyString())).thenReturn(false);
        when(passwordEncoder.encode(anyString())).thenReturn("encodedPassword");
        when(userMapper.insert(any(User.class))).thenReturn(1);

        RegisterRequest request = new RegisterRequest();
        request.setUsername("testuser");
        request.setEmail("test@example.com");
        request.setPassword("password");

        User result = userService.register(request);

        assertNotNull(result);
        assertEquals("testuser", result.getUsername());
        assertEquals("test@example.com", result.getEmail());
        assertEquals("ACTIVE", result.getStatus());
        assertEquals("USER", result.getRole());
        verify(userMapper, times(1)).insert(any(User.class));
        verify(passwordEncoder, times(1)).encode("password");
    }

    @Test
    void testRegister_UsernameExists() {
        when(userMapper.existsByUsername(anyString())).thenReturn(true);

        RegisterRequest request = new RegisterRequest();
        request.setUsername("testuser");
        request.setEmail("test2@example.com");
        request.setPassword("password");

        assertThrows(IllegalArgumentException.class, () -> userService.register(request));
        verify(userMapper, never()).insert(any(User.class));
    }

    @Test
    void testRegister_EmailExists() {
        when(userMapper.existsByUsername(anyString())).thenReturn(false);
        when(userMapper.existsByEmail(anyString())).thenReturn(true);

        RegisterRequest request = new RegisterRequest();
        request.setUsername("testuser2");
        request.setEmail("test@example.com");
        request.setPassword("password");

        assertThrows(IllegalArgumentException.class, () -> userService.register(request));
        verify(userMapper, never()).insert(any(User.class));
    }

    @Test
    void testFindById_Success() {
        when(userMapper.findById(1L)).thenReturn(testUser);

        User result = userService.findById(1L);

        assertNotNull(result);
        assertEquals(testUser, result);
        verify(userMapper, times(1)).findById(1L);
    }

    @Test
    void testFindById_NotFound() {
        when(userMapper.findById(anyLong())).thenReturn(null);

        assertThrows(IllegalArgumentException.class, () -> userService.findById(999L));
        verify(userMapper, times(1)).findById(999L);
    }

    @Test
    void testUpdateStatus_Success() {
        when(userMapper.findById(1L)).thenReturn(testUser);

        userService.updateStatus(1L, "DISABLED");

        verify(userMapper, times(1)).updateStatus(1L, "DISABLED");
    }

    @Test
    void testUpdateStatus_InvalidStatus() {
        when(userMapper.findById(1L)).thenReturn(testUser);

        assertThrows(IllegalArgumentException.class, () -> userService.updateStatus(1L, "UNKNOWN"));
        verify(userMapper, never()).updateStatus(anyLong(), anyString());
    }

    @Test
    void testDeleteUser() {
        when(userMapper.findById(1L)).thenReturn(testUser);

        userService.deleteUser(1L);

        verify(userMapper, times(1)).deleteById(1L);
    }

    @Test
    void testValidatePassword_Success() {
        when(passwordEncoder.matches(anyString(), anyString())).thenReturn(true);

        boolean result = userService.validatePassword(testUser, "rawPassword");

        assertTrue(result);
        verify(passwordEncoder, times(1)).matches("rawPassword", "encodedPassword");
    }

    @Test
    void testValidatePassword_Failure() {
        when(passwordEncoder.matches(anyString(), anyString())).thenReturn(false);

        boolean result = userService.validatePassword(testUser, "rawPassword");

        assertFalse(result);
        verify(passwordEncoder, times(1)).matches("rawPassword", "encodedPassword");
    }
}

