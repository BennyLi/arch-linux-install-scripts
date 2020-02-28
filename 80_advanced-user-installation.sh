#! /usr/bin/env sh

DIALOG_STEP_TITLE="Ansible Setup"
PROGRESS_PERCENTAGE=80

show_intro_screen() {
  show_info_box \
    "$DIALOG_STEP_TITLE" \
    $PROGRESS_PERCENTAGE \
    "Finally! Let's setup everything else with the power of ansible.\n\nIn the next minutes I will checkout your dotfile from Github, your ansible playbook from your defined git repository and then will execute your ansible playbook.\n\n Lean back and have a tea ..."

}

get_dotfiles() {
  DIALOG_SUBSTEP_TITLE="Get the dotfiles"

  arch-chroot /mnt git clone https://github.com/${GITHUB_DOTFILES_REPO}.git /home/$USERNAME/.dotfiles | \
    show_progress_box "$DIALOG_STEP_TITLE - $DIALOG_SUBSTEP_TITLE" $PROGRESS_PERCENTAGE "Getting your dotfiles ..."
}

get_ansible_playbook() {
  DIALOG_SUBSTEP_TITLE="Get the Ansible playbook"

  arch-chroot /mnt git clone $ANSIBLE_GIT_REPO_URL /home/$USERNAME/.ansible_playbook | \
    show_progress_box "$DIALOG_STEP_TITLE - $DIALOG_SUBSTEP_TITLE" $PROGRESS_PERCENTAGE "Getting your ansible playbook ..."
}

set_ansible_vault_password() {
  echo -n "$ANSIBLE_VAULT_PASSWORT" > /mnt/home/$USERNAME/.ansible_playbook/.vault_pass
  arch-chroot /mnt chown $USERNAME:$USERGROUP /home/$USERNAME/.ansible_playbook/.vault_pass
  arch-chroot /mnt chmod u=rw,g=,o= /home/$USERNAME/.ansible_playbook/.vault_pass
}

execute_ansible_playbook() {
  DIALOG_SUBSTEP_TITLE="Ansible playbook execution"

  cat << EOF > /mnt/usr/local/bin/run_ansible_laptop_playbook
#! /usr/bin/env sh
cd /home/$USERNAME/.ansible_playbook
./run.sh
EOF

  arch-chroot /mnt chmod +x /usr/local/bin/run_ansible_laptop_playbook
  arch-chroot /mnt /usr/local/bin/run_ansible_laptop_playbook | \
    show_progress_box "$DIALOG_STEP_TITLE - $DIALOG_SUBSTEP_TITLE" $PROGRESS_PERCENTAGE "Executing your ansible playbook ..."
}


##### -----> MAIN FUNCTION

show_intro_screen
PROGRESS_PERCENTAGE=$(( PROGRESS_PERCENTAGE + 1 ))

get_dotfiles
PROGRESS_PERCENTAGE=$(( PROGRESS_PERCENTAGE + 1 ))
get_ansible_playbook
PROGRESS_PERCENTAGE=$(( PROGRESS_PERCENTAGE + 1 ))
set_ansible_vault_password
execute_ansible_playbook


# vim: set tabstop=2 softtabstop=0 expandtab shiftwidth=2 number:
