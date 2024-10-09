using Facebook.Application.Authentication.ChangeEmail;
using Facebook.Application.Authentication.ConfirmEmail;
using Facebook.Application.Authentication.ForgotPassword;
using Facebook.Application.Authentication.Login;
using Facebook.Application.Authentication.Register;
using Facebook.Application.Authentication.ResendConfirmEmail;
using Facebook.Application.Authentication.ResetPassword;
using Facebook.Application.Common.Interfaces.Authentication;
using Facebook.Application.Common.Interfaces.Common;
using Facebook.Contracts.Authentication.ChangeEmail;
using Facebook.Contracts.Authentication.Common.Response;
using Facebook.Contracts.Authentication.ConfirmEmail;
using Facebook.Contracts.Authentication.ResendConfirmEmail;
using Facebook.Domain.Common.Errors;
using Facebook.Domain.User;
using MapsterMapper;
using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using LoginRequest = Facebook.Contracts.Authentication.Login.LoginRequest;
using RegisterRequest = Facebook.Contracts.Authentication.Register.RegisterRequest;
using ResetPasswordRequest = Facebook.Contracts.Authentication.ResetPassword.ResetPasswordRequest;

namespace Facebook.Server.Controllers;

[Route("api/authentication")]
[ApiController]
[AllowAnonymous]
public class AuthenticationController(ISender mediatr,
    IMapper mapper,
    IConfiguration configuration,
    IUserAuthenticationService authenticationService,
    UserManager<UserEntity> userManager,
    ICurrentUserService currentUserService,
    ILogger<AuthenticationController> logger)
    : ApiController
{
    [HttpPost("register")]
    public async Task<IActionResult> RegisterAsync([FromForm] RegisterRequest request)
    {
        logger.LogInformation($"Attempting to register user: {request.Email}");

        var baseUrl = configuration.GetRequiredSection("HostSettings:ClientURL").Value;

        byte[] image = null;
        if (request.Avatar != null && request.Avatar.Length > 0)
        {
            using MemoryStream memoryStream = new();
            await request.Avatar.CopyToAsync(memoryStream);
            image = memoryStream.ToArray();
        }

        var authResult = await mediatr.Send(mapper
            .Map<RegisterCommand>((request, baseUrl, image)));

        return authResult.Match(
            authResult =>
            {
                logger.LogInformation($"User registered: {request.Email}");
                return Ok(mapper.Map<AuthenticationResponse>(authResult));
            },
            errors =>
            {
                logger.LogError($"Registration failed for user: {request.Email}, Errors: {string.Join(", ", errors.Select(e => e.Description))}");
                return Problem(errors);
            });
    }

    [HttpGet("confirm-email")]
    public async Task<IActionResult> ConfirmEmailAsync([FromQuery] ConfirmEmailRequest request)
    {
        logger.LogInformation($"Attempting to confirm email for user: {request.UserId}");

        var confirmEmailResult = await mediatr.Send(mapper.Map<ConfirmEmailCommand>(request));

        return confirmEmailResult.Match(
            confirmResult =>
            {
                logger.LogInformation($"Email confirmed for user: {request.UserId}");
                return Redirect("http://3.72.8.43:5173");
            },
            errors =>
            {
                logger.LogError($"Email confirmation failed for user: {request.UserId}, Errors: {string.Join(", ", errors.Select(e => e.Description))}");
                return Problem(errors);
            });
    }

    [HttpGet("resend-confirmation-email")]
    public async Task<IActionResult> ResendConfirmationEmailAsync([FromQuery] ResendConfirmEmailRequest request)
    {
        logger.LogInformation($"Attempting to resend confirmation email for user: {request.Email}");

        var baseUrl = configuration.GetRequiredSection("HostSettings:ClientURL").Value;
        var resendConfirmationResult = await mediatr.Send(mapper
            .Map<ResendConfirmEmailCommand>((request, baseUrl)));

        return resendConfirmationResult.Match(
            success =>
            {
                logger.LogInformation($"Confirmation email resent for user: {request.Email}");
                return Ok("Confirmation email resent successfully");
            },
            errors =>
            {
                logger.LogError($"Resending confirmation email failed for user: {request.Email}, Errors: {string.Join(", ", errors.Select(e => e.Description))}");
                return Problem(errors);
            });
    }

    [HttpPost("login")]
    public async Task<IActionResult> LoginAsync([FromBody] LoginRequest request)
    {
        logger.LogInformation($"Attempting to authenticate user: {request.Email}");

        var query = mapper.Map<LoginQuery>(request);
        var authenticationResult = await mediatr.Send(query);

        if (authenticationResult.IsError && authenticationResult.FirstError == Errors.Authentication.InvalidCredentials)
        {
            logger.LogWarning($"Authentication failed for user: {request.Email}, Reason: Invalid credentials");
            return Problem(statusCode: StatusCodes.Status401Unauthorized, title: authenticationResult.FirstError.Description);
        }

        return authenticationResult.Match(
            authenticationResult =>
            {
                logger.LogInformation($"User authenticated: {request.Email}");
                return Ok(mapper.Map<AuthenticationResponse>(authenticationResult));
            },
            errors =>
            {
                logger.LogError($"Authentication failed for user: {request.Email}, Errors: {string.Join(", ", errors.Select(e => e.Description))}");
                return Problem(errors);
            });
    }

    [HttpGet("forgot-password")]
    public async Task<IActionResult> ForgotPasswordAsync([FromQuery] string email)
    {
        logger.LogInformation($"Attempting to send forgot password email for user: {email}");

        var baseUrl = Request.Headers["Referer"].ToString();

        var query = new ForgotPasswordQuery(email, baseUrl);

        var forgotPasswordResult = await mediatr.Send(query);

        return forgotPasswordResult.Match(
            forgotPasswordRes =>
            {
                logger.LogInformation($"Forgot password email sent for user: {email}");
                return Redirect("http://3.72.8.43:5173");
            },
            errors =>
            {
                logger.LogError($"Forgot password email failed for user: {email}, Errors: {string.Join(", ", errors.Select(e => e.Description))}");
                return Problem(errors);
            });
    }

    [HttpPost("reset-password")]
    public async Task<IActionResult> ResetPasswordAsync(ResetPasswordRequest request)
    {
        logger.LogInformation($"Attempting to reset password for user: {request.Email}");

        var baseUrl = configuration.GetRequiredSection("HostSettings:ClientURL").Value;

        var resetPasswordCommand = mapper.Map<ResetPasswordCommand>(request);
        resetPasswordCommand = resetPasswordCommand with { BaseUrl = baseUrl };

        var resetPasswordResult = await mediatr.Send(resetPasswordCommand);

        return resetPasswordResult.Match(
            resetPasswordRes =>
            {
                logger.LogInformation($"Password reset for user: {request.Email}");
                return Ok(resetPasswordResult.Value);
            },
            errors =>
            {
                logger.LogError($"Password reset failed for user: {request.Email}, Errors: {string.Join(", ", errors.Select(e => e.Description))}");
                return Problem(errors);
            });
    }

    [HttpPost("change-email")]
    public async Task<IActionResult> ChangeEmailAsync([FromBody] ChangeEmailRequest request)
    {
        logger.LogInformation($"Attempting to change email for user: {request.Email}");

        var baseUrl = configuration.GetRequiredSection("HostSettings:ClientURL").Value;
        var changeEmailCommand = mapper.Map<ChangeEmailCommand>(request);
        changeEmailCommand = changeEmailCommand with { BaseUrl = baseUrl };
        var changeEmailResult = await mediatr.Send(changeEmailCommand);

        return changeEmailResult.Match(
            changeEmailRes =>
            {
                logger.LogInformation($"Email changed for user: {request.Email}");
                return Ok(changeEmailResult.Value);
            },
            errors =>
            {
                logger.LogError($"Email change failed for user: {request.Email}, Errors: {string.Join(", ", errors.Select(e => e.Description))}");
                return Problem(errors);
            });
    }

    [HttpPost("logout")]
    public async Task<IActionResult> LogoutAsync()
    {
        logger.LogInformation("Attempting to log out user");

        var currentUserId = currentUserService.GetCurrentUserId();
        var logoutResult = await authenticationService.LogoutUserAsync(currentUserId);

        if (logoutResult.IsError)
        {
            logger.LogError($"Logout failed for user: {currentUserId}, Errors: {string.Join(", ", logoutResult.Errors.Select(e => e.Description))}");
            return Problem(logoutResult.Errors);
        }

        logger.LogInformation("User logged out successfully");
        return Ok("Logged out successfully");
    }

    [HttpGet("user-status/{userId}")]
    public async Task<IActionResult> GetUserStatusAsync(Guid userId)
    {
        logger.LogInformation($"Attempting to get user status for user: {userId}");

        var user = await userManager.FindByIdAsync(userId.ToString());
        if (user == null)
        {
            logger.LogWarning($"User not found: {userId}");
            return NotFound();
        }

        var status = new
        {
            IsOnline = user.IsOnline,
            LastActive = user.LastActive
        };

        logger.LogInformation($"User status retrieved for user: {userId}");
        return Ok(status);
    }

    [HttpGet("ping")]
    public IActionResult Ping()
    {
        logger.LogInformation("Ping request received");
        return Ok(DateTime.Now);
    }
}
