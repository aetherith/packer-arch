#!/usr/bin/bash -x

CLOUD_USER=$1
CLOUD_USER_PUBKEY_URL=$2

/usr/bin/useradd --comment 'Default Cloud User' --create-home --user-group $CLOUD_USER
CLOUD_USER_HOME_DIR=$( getent passwd "$CLOUD_USER" | cut -d: -f6 )
/usr/bin/install --directory \
    --owner=$CLOUD_USER \
    --group=$CLOUD_USER \
    --mode=0700 \
    $CLOUD_USER_HOME_DIR/.ssh
/usr/bin/curl \
    --silent \
    --location $CLOUD_USER_PUBKEY_URL \
    --output $CLOUD_USER_HOME_DIR/.ssh/authorized_keys
/usr/bin/chown $CLOUD_USER:$CLOUD_USER $CLOUD_USER_HOME_DIR/.ssh/authorized_keys
/usr/bin/chmod 0600 $CLOUD_USER_HOME_DIR/.ssh/authorized_keys
echo 'Defaults env_keep += "SSH_AUTH_SOCK"' > /etc/sudoers.d/10_cloud_user
echo "$CLOUD_USER ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers.d/10_cloud_user
/usr/bin/chmod 0440 /etc/sudoers.d/10_cloud_user
/usr/bin/systemctl start sshd.service
