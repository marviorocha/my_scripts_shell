#!/bin/bash
echo "Tarefa executada em: $(date)" >> /home/marviorocha/log_cron.txt
mv /home/marviorocha/Downloads/*.ogg /home/marviorocha/Music/Audio
mv /home/marviorocha/Downloads/*.mp3 /home/marviorocha/Music/Audio
