using api.Models;
using api.Services;
using Microsoft.AspNetCore.Mvc;

namespace api.Controllers;

[ApiController]
[Route("api/users")]
public class UsersController : ControllerBase
{
    private readonly UsersService _usersService;

    public UsersController(UsersService usersService) =>
        _usersService = usersService;

    [HttpGet]
    public async Task<List<User>> Get() =>
        await _usersService.GetAsync();

    [HttpGet("{id:length(24)}")]
    public async Task<ActionResult<User>> Get(string id)
    {
        var User = await _usersService.GetAsync(id);

        if (User is null)
        {
            return NotFound();
        }

        return User;
    }

    [HttpPost]
    public async Task<IActionResult> Post(User user)
    {
        await _usersService.CreateAsync(user);

        return CreatedAtAction(nameof(Get), new { id = user.Id }, user);
    }

    [HttpPut("{id:length(24)}")]
    public async Task<IActionResult> Update(string id, User updatedUser)
    {
        var User = await _usersService.GetAsync(id);

        if (User is null)
        {
            return NotFound();
        }

        updatedUser.Id = User.Id;

        await _usersService.UpdateAsync(id, updatedUser);

        return NoContent();
    }

    [HttpDelete("{id:length(24)}")]
    public async Task<IActionResult> Delete(string id)
    {
        var User = await _usersService.GetAsync(id);

        if (User is null)
        {
            return NotFound();
        }

        await _usersService.RemoveAsync(id);

        return NoContent();
    }
}