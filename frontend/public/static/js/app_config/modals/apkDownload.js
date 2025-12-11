class ApkDownloadModal {
    __html = `
    <div class="modal-dialog modal-md">
        <div class="modal-content">
            <div class="modal-header">
                <h1 class="modal-title fs-5" id="exampleModalToggleLabel">DESCARGAR EL APK</h1>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body p-2">
                <div class="d-flex flex-column gap-2 justify-content-center">

                    <!-- Grupo Ayuda -->
                    <div class="card">
                        <div class="card-body p-2">
                            <h5 class="card-title d-flex justify-content-center">Grupo Ayuda</h5>
                            <p class="card-text">Únete al grupo para recibir ayuda de la comunidad, soporte del creador y miembros del grupo.</p>
                            <a href="https://t.me/+9-aFIbCVPUIxNjdh" class="btn btn-dark w-100 mt-2">IR AL GRUPO</a>
                        </div>
                    </div>

                    <!-- Segundo Grupo -->
                    <div class="card">
                        <div class="card-body p-2">
                            <h5 class="card-title d-flex justify-content-center">Grupo 2</h5>
                            <p class="card-text">Enlace alternativo a otro grupo de soporte o comunidad.</p>
                            <a href="https://whatsapp.com/channel/0029VbBKUIAL7UVQLgYs5S1b" class="btn btn-dark w-100 mt-2">IR AL GRUPO</a>
                        </div>
                    </div>

                    <!-- SOLO V2RAY -->
                    <div class="card">
                        <div class="card-body p-2">
                            <h5 class="card-title d-flex justify-content-center">DTUNNEL V2RAY</h5>
                            <p class="card-text">Versión con modos de conexión SSH, OpenVPN y V2RAY.</p>
                            <a href="https://t.me/+9-aFIbCVPUIxNjdh" class="btn btn-dark w-100 mt-2">DESCARGAR</a>
                        </div>
                    </div>

                </div>
            </div>
        </div>
    </div>`

    constructor() {
        this._element = document.createElement('div');
        this._element.classList.add('modal', 'fade');
        this._element.setAttribute('tabindex', '-1');
        this._element.innerHTML = this.__html;

        this._root = this._element.querySelector('.modal-body');
        this.modal = new bootstrap.Modal(this._element);
    }

    setApp(app) {
        this._root.innerHTML = '';
        this._root.append(app.element);
    }

    setFooter(footer) {
        this._root.append(footer.element);
    }

    show() {
        this.modal.show();
    }

    hide() {
        this.modal.hide();
    }
}

export default ApkDownloadModal;