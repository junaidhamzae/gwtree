# gwtree - Git Worktree Management Tool

`gwtree` is a command-line tool that simplifies working with Git worktrees by providing an intuitive interface for creating, switching between, and managing multiple branches in separate worktrees.

## Features

- Create new worktrees with branches
- Switch between worktrees easily
- Delete worktrees when no longer needed
- Configurable protected branches
- Configurable worktree directory location
- Automatic branch name to directory mapping
- Tab completion for branch names and commands

## Prerequisites

- Git
- Zsh shell
- Oh-My-Zsh (recommended)

## Installation

### Via npm (Recommended)

The easiest way to install `gwtree` is via npm:

```bash
npm install -g gwtree
```

After installation, add the following to your ~/.zshrc:
```bash
# Load gwtree completion
source $(npm root -g)/gwtree/lib/gwtree.sh
```

### Via Manual Installation

1. Clone this repository:
   ```bash
   git clone https://github.com/junaidhamzae/gwtree.git
   ```

2. Run the installation script:
   ```bash
   cd gwtree
   make install
   ```

   Or manually:
   ```bash
   sudo cp bin/gwtree /usr/local/bin/
   sudo cp lib/gwtree.sh /usr/local/lib/
   sudo cp man/man1/gwtree.1 /usr/local/share/man/man1/
   ```

3. Add the following to your ~/.zshrc:
   ```bash
   # Load gwtree completion
   source /usr/local/lib/gwtree.sh
   ```

4. Reload your shell:
   ```bash
   source ~/.zshrc
   ```

## Configuration

You can configure gwtree using the configuration command:

```bash
gwtree config
```

This will prompt you to set:
1. The directory where worktrees will be stored (default: ../alternate-worktrees)
2. The list of protected branches that cannot be deleted (default: master quality main develop)

The configuration is stored in `~/.gwtreerc` and can be edited manually if needed.

## Usage

### Basic Commands

1. List all worktrees:
   ```bash
   gwtree
   ```

2. Create a new worktree with a new branch:
   ```bash
   gwtree -b feature/new-feature
   ```

3. Switch to an existing branch's worktree:
   ```bash
   gwtree feature/existing-feature
   ```

4. Delete a worktree:
   ```bash
   gwtree -d feature/old-feature
   ```

5. Update configuration:
   ```bash
   gwtree config
   ```

### Directory Structure

The tool creates worktrees in your configured worktree directory (default: alternate-worktrees) parallel to your main repository, organizing them by repository and branch names:

```
your-project/                 # Main repository
alternate-worktrees/         # Worktrees directory (configurable)
└── repo-name/              # Repository-specific directory
    ├── feature-branch-1/   # Worktree for feature/branch-1
    └── feature-branch-2/   # Worktree for feature/branch-2
```

### Configuration File

The configuration file at `~/.gwtreerc` contains:

```bash
# gwtree configuration file
GWTREE_WORKTREE_PATH="../alternate-worktrees"  # Can be relative or absolute path
GWTREE_PROTECTED_BRANCHES=(master quality main develop)  # Space-separated list of protected branches
```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

MIT License - see the [LICENSE](LICENSE) file for details.

## Author

Junaid Hamza 