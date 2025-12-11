import { Render } from '../../../config/render-config';
import Authentication from '../../../middlewares/authentication';
import csrfProtection from '../../../middlewares/csrf-protection';
import { FastifyRequest, FastifyReply, RouteOptions } from 'fastify';

export default {
  url: '/register',
  method: 'GET',
  onRequest: [Authentication.user],
  handler: async (req: FastifyRequest, reply: FastifyReply) => {
    if (req.user && req.user.id) return reply.redirect('/');

    // Generamos el token CSRF usando tu middleware
    const csrfToken = await csrfProtection.generateToken(req, reply);

    // Renderizamos la página con el token
    Render.page(req, reply, '/register/index.html', { csrfToken });
  },
} as RouteOptions;