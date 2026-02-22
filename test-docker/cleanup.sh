#!/bin/bash
# Docker 环境清理脚本
# 停止容器、删除镜像、清理临时文件

echo "🧹 清理 Docker 测试环境"
echo "======================================"
echo ""

echo "选择清理级别："
echo "1. 轻度清理（停止容器，保留镜像和配置）"
echo "2. 中度清理（停止并删除容器，保留镜像）"
echo "3. 完全清理（删除容器、镜像、配置、日志）"
echo ""
read -p "请选择 [1-3]: " choice

case $choice in
    1)
        echo ""
        echo "🛑 停止容器..."
        docker-compose stop
        echo "✓ 容器已停止"
        echo ""
        echo "💡 提示: 使用 docker-compose start 可以重新启动"
        ;;
    2)
        echo ""
        echo "🛑 停止并删除容器..."
        docker-compose down
        echo "✓ 容器已删除"
        echo ""
        echo "💡 提示: 镜像和配置文件已保留，运行 ./init-env.sh 可快速重建"
        ;;
    3)
        echo ""
        read -p "⚠️  确认完全清理？这将删除所有数据 [y/N]: " confirm
        if [ "$confirm" = "y" ] || [ "$confirm" = "Y" ]; then
            echo ""
            echo "🛑 停止并删除容器..."
            docker-compose down

            echo ""
            echo "🗑️  删除 Docker 镜像..."
            docker-compose down --rmi all

            echo ""
            echo "🗑️  清理配置文件..."
            rm -rf .claude
            echo "✓ .claude/ 已删除"

            rm -f .env
            echo "✓ .env 已删除"

            echo ""
            echo "🗑️  清理日志文件..."
            rm -rf agent_logs
            echo "✓ agent_logs/ 已删除"

            rm -f /tmp/claude_test_output.txt /tmp/claude_skip_test.txt
            echo "✓ 临时日志文件已删除"

            echo ""
            echo "✅ 完全清理完成！"
        else
            echo "❌ 已取消清理"
            exit 0
        fi
        ;;
    *)
        echo "❌ 无效选择"
        exit 1
        ;;
esac

echo ""
echo "======================================"
echo "✅ 清理完成"
echo ""
