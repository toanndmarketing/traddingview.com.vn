#!/bin/bash
# Script to clear Ghost security alerts from database
DB_USER="ghost-814"
DB_PASS="Tr@dingV!ew_User_2025!"
DB_NAME="ghostproduction"
CONTAINER="ghost-mysql"

echo "Clearing Ghost announcements and notifications..."
docker exec $CONTAINER mysql -u $DB_USER -p$DB_PASS $DB_NAME -e "UPDATE settings SET value=NULL WHERE \`key\`='announcement';" || true
docker exec $CONTAINER mysql -u $DB_USER -p$DB_PASS $DB_NAME -e "DELETE FROM settings WHERE \`key\`='notifications';" || true
docker exec $CONTAINER mysql -u $DB_USER -p$DB_PASS $DB_NAME -e "DELETE FROM settings WHERE \`key\` LIKE '%notification%';" || true

echo "Done."
