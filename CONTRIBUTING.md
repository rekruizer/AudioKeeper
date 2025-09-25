# Contributing to AudioKeeper

Thank you for your interest in contributing to AudioKeeper! 🎧

## 🤝 How to Contribute

### Reporting Bugs
- Use the GitHub issue tracker
- Include macOS version and AudioKeeper version
- Provide steps to reproduce the issue
- Attach relevant logs or screenshots

### Suggesting Features
- Open an issue with the "enhancement" label
- Describe the feature and its use case
- Consider if it aligns with the app's core purpose

### Code Contributions
1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Make your changes
4. Test thoroughly on different macOS versions
5. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
6. Push to the branch (`git push origin feature/AmazingFeature`)
7. Open a Pull Request

## 🏗️ Development Setup

### Prerequisites
- macOS 13.0+
- Xcode 14.0+
- Git

### Getting Started
```bash
# Clone your fork
git clone https://github.com/yourusername/AudioKeeper.git
cd AudioKeeper

# Open in Xcode
open AudioKeeper.xcodeproj

# Build and test
# Press Cmd + R in Xcode
```

## 📝 Code Style

### Swift Guidelines
- Follow Swift API Design Guidelines
- Use meaningful variable and function names
- Add comments for complex logic
- Keep functions focused and small

### Project Structure
- Keep the existing folder structure
- Place new files in appropriate directories
- Update documentation when adding features

## 🧪 Testing

### Before Submitting
- Test on multiple macOS versions (13.0+)
- Test with different audio devices
- Ensure no memory leaks
- Verify menu bar behavior

### Test Scenarios
- Connect/disconnect audio devices
- Change system audio settings manually
- Restart the application
- Test with different user preferences

## 📚 Documentation

### Required Updates
- Update README.md for new features
- Update project documentation
- Include code comments

### Documentation Structure
- Keep documentation in `AudioKeeper/Documentation/`
- Use clear, concise language
- Include examples where helpful

## 🚀 Release Process

### Version Bumping
- Update version in `Info.plist`
- Update version in documentation
- Create a release tag

### Release Notes
- List new features
- Mention bug fixes
- Include breaking changes (if any)
- Provide upgrade instructions

## 📋 Pull Request Guidelines

### Before Submitting
- [ ] Code follows project style
- [ ] Tests pass on your machine
- [ ] Documentation is updated
- [ ] No breaking changes (or clearly documented)
- [ ] Commit messages are clear

### PR Description Template
```markdown
## Description
Brief description of changes

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Documentation update
- [ ] Performance improvement

## Testing
- [ ] Tested on macOS 13.0+
- [ ] Tested with multiple audio devices
- [ ] No memory leaks detected

## Screenshots (if applicable)
Add screenshots for UI changes
```

## 🏷️ Issue Labels

- `bug`: Something isn't working
- `enhancement`: New feature or request
- `documentation`: Documentation improvements
- `help wanted`: Extra attention is needed
- `good first issue`: Good for newcomers
- `priority: high`: High priority issues

## 💬 Communication

- Use GitHub Issues for bug reports and feature requests
- Use GitHub Discussions for questions and general discussion
- Be respectful and constructive in all communications

## 📄 License

By contributing, you agree that your contributions will be licensed under the MIT License.

## 🙏 Recognition

Contributors will be recognized in:
- README.md acknowledgments
- Release notes
- GitHub contributors list

Thank you for helping make AudioKeeper better! 🎧✨
