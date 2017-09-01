#!/bin/bash
AGENT_NAME=$(docker node ls -f "role=worker" -q |head -1)
MASTER_NAME=$(docker node ls -f "role=manager" -q)
docker node update --availability active $MASTER_NAME
docker node  promote $AGENT_NAME
sleep 7
docker node demote $AGENT_NAME
